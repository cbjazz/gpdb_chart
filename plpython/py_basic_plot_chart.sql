CREATE OR REPLACE FUNCTION home_project.py_basic_plot_chart(
	p_x text, 
	p_y text,
	p_title text,
	p_legend text,
	p_sequence text,
	p_option text)
RETURNS text
    LANGUAGE 'plpythonu'
    COST 100
    VOLATILE 
AS $BODY$
import base64
import io
import StringIO
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.cm as cmx
import numpy as np
import pandas as pd
import json

class MyChartOption:
    def __init__(self, jsonString):
        self.json = json.loads(jsonString)

    def getOption(self, option_name):
        tokens = option_name.split('.')
        value = self.json
        for token in tokens:
            if token in value:
                value = value[token]
            else: 
                return None
        return value
    
    def isExist(self, option_name):
        tokens = option_name.split('.')
        value = self.json
        for token in tokens:
            if token in value:
                value = value[token]
            else: 
                return False
        return True

def drawPlotChart(X, Y, title, legend, sequence, options):
    u_legend = np.unique(legend)
    
    """
    Set style option
    """
    if options.isExist('style'):
        plt.style.use(options.getOption('style'))
    
    """
    Set figure options
    """
    if options.isExist('fig'):
        fig_size_x = options.getOption('fig.x_size')
        fig_size_y = options.getOption('fig.y_size')
        
    """
    Set legend options
    """
    if options.isExist('legend'):
        legend_loc = options.getOption('legend.loc')

    """
    Set color map
    """
    if options.isExist('color'):
        color_map = []
        if (options.isExist('color.pallete')):
            color_map = options.getOption('color.pallete')
        elif (options.isExist('color.map')):
            color_norm = colors.Normalize(vmin=0, vmax=len(u_legend)-1)
            scalar_map = cmx.ScalarMappable(norm=color_norm, cmap = options.getOption('color.map'))       
            for i in range(len(u_legend)):
                color_map.append(scalar_map.to_rgba(i))
    """
    Set axes options
    """
    if options.isExist('axes'):
        axes_alpha = options.getOption('axes.alpha')
        axes_format = options.getOption('axes.format')
        axes_markersize = options.getOption('axes.markersize')
        axes_linewidth = options.getOption('axes.linewidth')
  
    imgdata = StringIO.StringIO()
    fig, ax = plt.subplots()
    fig.set_size_inches(fig_size_x, fig_size_y)  
    ax.set_title(title)
    
    if sequence != None:
        seq = []
        for i in range(len(u_legend)):
            seq.append(sequence[np.where(legend==u_legend[i])][0])
        sorted_seq_index = np.argsort(seq)
    else:
        seq = np.arange(len(u_legend))
        sorted_seq_index = np.arange(len(u_legend))
        
    for i in sorted_seq_index:
        subX = X[np.where(legend==u_legend[i])]
        subY = Y[np.where(legend==u_legend[i])]

        ax.plot(subX, subY, axes_format, 
                ms=axes_markersize, 
                lw=axes_linewidth, 
                alpha=axes_alpha, 
                color=color_map[seq[i]],
                label=u_legend[i])
    ax.legend(loc = legend_loc, fontsize='x-small')
    plt.savefig(imgdata, format='png')
    imgdata.seek(0)
    return base64.b64encode(imgdata.buf)

X = np.array(p_x.split(','))
Y = np.array(p_y.split(','))
title = p_title
legend = np.array(p_legend.split(','))
if p_sequence:
    seq = np.array(p_sequence.split(','))
else:
    seq = None
if p_option:
	opt = MyChartOption(p_option)
else:
	opt = None
return drawPlotChart(X, Y, title, legend, seq, opt)
$BODY$;
