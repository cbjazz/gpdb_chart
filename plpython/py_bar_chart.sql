-- FUNCTION: home_project.py_ma_band_plot_chart(text, text, text, integer, double precision, text)

-- DROP FUNCTION home_project.py_ma_band_plot_chart(text, text, text, integer, double precision, text);

CREATE OR REPLACE FUNCTION home_project.py_bar_chart(
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
import matplotlib as mpl
mpl.use('Agg')
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

def mergeLegend(X, Y, legends):
    unique_x = np.unique(X)
    unique_legend = np.unique(legends)
    
    df_merge = pd.DataFrame(
        {
            'X': unique_x
        }
    )

    for legend in unique_legend:
        df = pd.DataFrame (
            {
                'X' : X[np.where(legends==legend)], 
                'Y_' + legend : Y[np.where(legends==legend)]
            }
        )
        df_merge = df_merge.merge(df, how='left', on=['X'])
        
    return df_merge

def drawBarChart(X, Y, title, legend, sequence,  
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
            scalar_map = cmx.ScalarMappable(norm=color_norm, cmap = options.getOption('color.map'))       
            for i in range(u_legend_cnt):
                color_map.append(scalar_map.to_rgba(i))
    """
    Set axes options
    """
    if options.isExist('axes'):
        axes_alpha = options.getOption('axes.alpha')
        axes_format = options.getOption('axes.format')
        axes_markersize = options.getOption('axes.markersize')
        axes_linewidth = options.getOption('axes.linewidth')
        axes_barwidth = options.getOption('axes.barwidth')
        
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
        
    df = mergeLegend(X, Y, legend) 
    
    idx = 0 
    for i in sorted_seq_index:
        subX = df['X']
        subY = df['Y_' + u_legend[i]]
        
        ax.bar(np.array(df.index.tolist()) + (axes_barwidth * idx), subY, axes_barwidth, 
                alpha=axes_alpha, 
                color=color_map[seq[i]],
                label=u_legend[i])
        idx = idx + 1
    ax.set_xticks(np.array(df.index.tolist()) + axes_barwidth/u_legend_cnt)    
    ax.set_xticklabels(df['X'])
        
    ax.legend(loc = legend_loc, fontsize='x-small')    
    plt.savefig(imgdata, format='png')
    imgdata.seek(0)
    return base64.b64encode(imgdata.buf)
			  
X = np.array(p_x.split(','))
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

return drawBarChart(X, Y, title, legend, sequence, opt)
$BODY$;

