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
    color_map = [scalar_map.to_rgba(i, alpha=alpha)
                 for i in range(max_legend_cnt)]
    return color_map

def set_cycler(json_dic,max_legend_cnt=1):
    # Set color cycler
    color_map = []
    alpha = 1.0
    if OPT_COLOR_ALPHA in json_dic.keys():
        alpha = json_dic[OPT_COLOR_ALPHA]
    if OPT_COLOR_MAP in json_dic.keys():
        color_map = set_color_map(json_dic[OPT_COLOR_MAP],
                                  alpha, max_legend_cnt)
    if OPT_COLOR_PALLETE in json_dic.keys():
        color_map = [colors.to_rgba(val, alpha=alpha)
                     for val in json_dic[OPT_COLOR_PALLETE]]
    if color_map:
        mpl.rcParams[OPT_PROP_CYCLE] = cycler(color = color_map)

def set_mpl_option(json_dic):
    for key in json_dic.keys():
        if key not in non_mpl_options:
            mpl.rcParams[key] = json_dic[key]

def draw_plot_chart(x, y, title, legend, sequence, options):
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

    for i in sorted_seq_index:
        sub_x = x[np.where(legend==u_legend[i])]
        sub_y = y[np.where(legend==u_legend[i])]
        ax.plot(sub_x, sub_y, label=u_legend[i])

    ax.legend()
    plt.savefig(imgdata, format='png')
    imgdata.seek(0)
    return base64.b64encode(imgdata.buf)

X = np.array(p_x.split(','))
Y = np.array(p_y.split(','))
title = p_title
if p_legend:
	legend = np.array(p_legend.split(','))
else:
	legend = np.array([])

if p_sequence:
    seq = np.array(p_sequence.split(','))
else:
    seq = np.array([])

return draw_plot_chart(X, Y, p_title, legend, seq, p_option)
$BODY$;
