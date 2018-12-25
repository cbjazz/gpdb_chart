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
import matplotlib.colors as colors
import matplotlib.cm as cmx
from cycler import cycler
from matplotlib.patches import Polygon
import numpy as np
import json

'''
Set chart options
'''
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

def draw_box_chart(y, title, legend, sequence, 
					 whiskers_legnth = 1.5, 
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
        
    set_mpl_option(option_dict)

    # Set color map
    color_map = []
    alpha = 1.0
    if OPT_COLOR_ALPHA in option_dict.keys():
        alpha = option_dict[OPT_COLOR_ALPHA]
    if OPT_COLOR_MAP in option_dict.keys():
        color_map = set_color_map(option_dict[OPT_COLOR_MAP], alpha, u_legend_cnt)
    else:
        color_map = set_color_map('hsv', alpha, u_legend_cnt)
    if OPT_COLOR_PALLETE in option_dict.keys():
        color_map = option_dict[OPT_COLOR_PALLETE]
        
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

    data = []
    sorted_legend = []
    if u_legend_cnt > 1:
        for i in sorted_seq_index:
            sub_y = y[np.where(legend==u_legend[i])]
            data.append(sub_y)
            sorted_legend.append(u_legend[i])
    else:
        data.append(y)
        sorted_legend.append(title)
        
        
    bp = ax.boxplot(data, 
                    patch_artist=True,
                    whis=whiskers_legnth)
    
    for i in range(u_legend_cnt):
        box = bp['boxes'][i]
        box.set_facecolor(color_map[i])
    
    plt.savefig(imgdata, format='png')
    imgdata.seek(0)
    return base64.b64encode(imgdata.buf)
			  

Y = np.array(p_y.split(',')).astype('float')
legend = np.array(p_legend.split(','))
if p_sequence:
	sequence = np.array(p_sequence.split(',')).astype('int')
else:
	sequence = np.array([])

if p_whiskers_legnth:
	whiskers = p_whiskers_legnth
else:
	whiskers = 1.5
										 
return draw_box_chart(Y, p_title, legend, sequence, whiskers, p_option)
$BODY$;

ALTER FUNCTION home_project.py_box_plot_chart(text, text, text, text, double precision, text)
    OWNER TO gpadmin;

