-- FUNCTION: home_project.py_box_plot_chart(text, text, text, text, double precision, text)

-- DROP FUNCTION home_project.py_box_plot_chart(text, text, text, text, double precision, text);

CREATE OR REPLACE FUNCTION home_project.py_box_plot_chart(
	p_y text,
	p_title text,
	p_legend text,
	p_sequence text,
	p_whiskers_legnth double precision,
	p_option text)
RETURNS text
    LANGUAGE 'plpythonu'
    COST 100
    VOLATILE 
AS $BODY$
import matplotlib as mpl
mpl.use('Agg')
import base64
import io
import StringIO
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
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

def drawBoxPlotChart(Y, title, legend, sequence, 
					 whiskers_legnth = 1.5, 
					 options = None):
    imgdata = StringIO.StringIO()

    if legend.size != 0:
        u_legend = np.unique(legend)
        u_legend_cnt = len(u_legend)
    else:
        u_legend = np.array([title])
        u_legend_cnt = 1
    
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
            color_norm = colors.Normalize(vmin=0, vmax=u_legend_cnt)
            scalar_map = cmx.ScalarMappable(norm=color_norm, 
                                cmap = options.getOption('color.map'))       
            for i in range(u_legend_cnt):
                color_map.append(scalar_map.to_rgba(i))
    """
    Set axes options
    """
    if options.isExist('axes'):
        axes_alpha = options.getOption('axes.alpha')
        axes_format = options.getOption('axes.format')
        axes_marker = options.getOption('axes.marker')
        axes_markersize = options.getOption('axes.markersize')
        axes_linewidth = options.getOption('axes.linewidth')
        if options.isExist('axes.vertical'):
            axes_vertical = 1 
        else: 
            if options.getOption('axes.vertical') == 'true':
                axes_vertical = 1
            else:
                axes_vertical = 0
    
    """
    Set x-axis options
    """
    if options.isExist('x_axis'):
        x_axis_rotation = options.getOption('x_axis.rotation')
        x_axis_fontsize = options.getOption('x_axis.fontsize')
        
        
    fig, ax = plt.subplots()
    fig.set_size_inches(fig_size_x, fig_size_y)  
    ax.set_title(title)
    
    if sequence.size != 0:
        seq = []
        for i in range(u_legend_cnt):
            seq.append(sequence[np.where(legend==u_legend[i])][0])
        sorted_seq_index = np.argsort(seq)
    else:
        seq = np.arange(u_legend_cnt)
        sorted_seq_index = np.arange(u_legend_cnt)

    data = []
    sorted_legend = []
    if u_legend_cnt > 1:
        for i in sorted_seq_index:
            subY = Y[np.where(legend==u_legend[i])]
            data.append(subY)
            sorted_legend.append(u_legend[i])
    else:
        data.append(Y)
        sorted_legend.append(title)
        
        
    bp = ax.boxplot(data, 
                    notch=0, 
                    sym=axes_marker, 
                    patch_artist=True,
                    vert=axes_vertical, 
                    whis=whiskers_legnth)
    
    for i in range(u_legend_cnt):
        box = bp['boxes'][i]
        box.set_facecolor(color_map[i])
    
    ax.set_xticklabels(sorted_legend, 
                       rotation=x_axis_rotation, 
                       fontsize=x_axis_fontsize)
    
    plt.savefig(imgdata, format='png')
    imgdata.seek(0)
    return base64.b64encode(imgdata.buf)
			  

Y = np.array(p_y.split(',')).astype('float')
legend = np.array(p_legend.split(','))
if p_sequence:
	sequence = np.array(p_sequence.split(',')).astype('int')
else:
	sequence = np.array([])

title = p_title

if p_option:
	opt = MyChartOption(p_option)
else:
	opt = None

if p_whiskers_legnth:
	whiskers = p_whiskers_legnth
else:
	whiskers = 1.5
return drawBoxPlotChart(Y, title, legend, sequence, whiskers, opt)
$BODY$;

ALTER FUNCTION home_project.py_box_plot_chart(text, text, text, text, double precision, text)
    OWNER TO gpadmin;

