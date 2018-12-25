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
from cycler import cycler 
import numpy as np
import json
import pandas as pd

"""
Set chart options
"""
OPT_STYLE = 'style'
OPT_COLOR_MAP = 'axes.color_map'
OPT_COLOR_PALLETE = 'axes.color_pallete'
OPT_COLOR_ALPHA = 'axes.color_alpha'
OPT_PROP_CYCLE = 'axes.prop_cycle'
OPT_BAR_WIDTH = 'axes.bar_width'
OPT_BAND_COLOR = 'axes.band_color'
OPT_BAND_COLOR_ALPHA = 'axes.band_color_alpha'

non_mpl_options = [
    OPT_STYLE, 
    OPT_COLOR_MAP, 
    OPT_COLOR_PALLETE, 
    OPT_COLOR_ALPHA, 
    OPT_BAR_WIDTH,
    OPT_BAND_COLOR,
    OPT_BAND_COLOR_ALPHA
]

def set_color_map(values, alpha=1.0, max_legend_cnt=1):
    color_map = []
    color_norm = colors.Normalize(vmin=0, vmax=max_legend_cnt)
    scalar_map = cmx.ScalarMappable(norm=color_norm,
                                   cmap=values)
    color_map = [scalar_map.to_rgba(i, alpha=alpha) for i in range(max_legend_cnt)]
    return color_map

def set_cycler(json_dic,max_legend_cnt=1): 
    # Set color cycler
    color_map = []
    alpha = 1.0
    if OPT_COLOR_ALPHA in json_dic.keys():
        alpha = json_dic[OPT_COLOR_ALPHA]
    if OPT_COLOR_MAP in json_dic.keys():
        color_map = set_color_map(json_dic[OPT_COLOR_MAP], alpha, max_legend_cnt)
    if OPT_COLOR_PALLETE in json_dic.keys():
        color_map = [colors.to_rgba(val, alpha=alpha) for val in json_dic[OPT_COLOR_PALLETE]]
    if color_map:
        mpl.rcParams[OPT_PROP_CYCLE] = cycler(color = color_map)
    
def set_mpl_option(json_dic):
    for key in json_dic.keys():
        if key not in non_mpl_options:
            mpl.rcParams[key] = json_dic[key]
            
def set_bar_width(x_size, x_cnt, legend_cnt):
    return (x_size / (x_cnt * legend_cnt))*2

"""
Merge all regend into dataframe with same index.
"""
def merge_legend(X, Y, legends):
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

"""
Draw chart
"""
def draw_bar_chart(x, y, title, legend, sequence,  
					 options = None):
    imgdata = StringIO.StringIO()

    if legend.size != 0:
        u_legend = np.unique(legend)
        u_legend_cnt = len(u_legend)
    else:
        u_legend = np.array([title])
        u_legend_cnt = 1
    
    # Set style options
    option_dict = json.loads(options)
    
    if OPT_STYLE in option_dict.keys():
        plt.style.use(option_dict[OPT_STYLE])

    if (OPT_COLOR_MAP in option_dict.keys()
        or OPT_COLOR_PALLETE in option_dict.keys()):
        set_cycler(option_dict, u_legend_cnt)
        
    set_mpl_option(option_dict)
    
	# Draw chart and bind data
    fig, ax = plt.subplots()
    ax.set_title(title)
    
    if sequence.size != 0:
        seq = []
        for i in range(u_legend_cnt):
            seq.append(sequence[np.where(legend==u_legend[i])][0])
        sorted_seq_index = np.argsort(seq)
    else:
        seq = np.arange(u_legend_cnt)
        sorted_seq_index = np.arange(u_legend_cnt)
        
    df = merge_legend(x, y, legend) 
    
    # Set bar width
    if (OPT_BAR_WIDTH in option_dict.keys()):
        axes_barwidth = option_dict[OPT_BAR_WIDTH]
    else:
        bbox = ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted())
        axes_barwidth = set_bar_width(bbox.width, df.shape[0], u_legend_cnt)    
    
    idx = 0 
    for i in sorted_seq_index:
        subX = df['X']
        subY = df['Y_' + u_legend[i]]
        
        ax.bar(np.array(df.index.tolist()) + (axes_barwidth * idx), subY, 
                axes_barwidth, 
                label=u_legend[i])
        idx = idx + 1
    ax.set_xticks(np.array(df.index.tolist()) + axes_barwidth/u_legend_cnt)    
    ax.set_xticklabels(df['X'])
        
    ax.legend()  
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

return draw_bar_chart(X, Y, p_title, legend, sequence, p_option)
$BODY$;

