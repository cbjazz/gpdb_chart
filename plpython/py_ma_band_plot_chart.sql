CREATE OR REPLACE FUNCTION home_project.py_ma_band_plot_chart(
	p_x text, 
	p_y text,
	p_title text,
	p_window_size int,
	p_sigma float,
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
import pandas as pd
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
        color_map = [colors.to_rgba(val, alpha=alpha) 
					 for val in json_dic[OPT_COLOR_PALLETE]]
    if color_map:
        mpl.rcParams[OPT_PROP_CYCLE] = cycler(color = color_map)
    
def set_mpl_option(json_dic):
    for key in json_dic.keys():
        if key not in non_mpl_options:
            mpl.rcParams[key] = json_dic[key]

def calculate_band(df, window_size=1, sigma=2.0):
    df['MA'] = df['Y'].rolling(window=window_size).mean()
    df['STD'] = df['Y'].rolling(window=window_size).std()
    df['U_band'] = df['MA'] + (df['STD'] * sigma)
    df['L_band'] = df['MA'] - (df['STD'] * sigma)
    return df
	
def draw_ma_band_plot_chart(x, y, title, window_size, sigma, options):
    imgdata = StringIO.StringIO()

    # Set style options
    option_dict = json.loads(options)
    
    if OPT_STYLE in option_dict.keys():
        plt.style.use(option_dict[OPT_STYLE])

    if (OPT_COLOR_MAP in option_dict.keys()
        or OPT_COLOR_PALLETE in option_dict.keys()):
        set_cycler(option_dict, 3)
        
    if (OPT_BAND_COLOR in option_dict.keys()):
        band_color = option_dict[OPT_BAND_COLOR]
    else:
        band_color = 'y'
    
    band_alpha = 0.5
    if (OPT_BAND_COLOR_ALPHA in option_dict.keys()):
        band_alpha = option_dict[OPT_BAND_COLOR_ALPHA]
        
    set_mpl_option(option_dict)
        
    frame = {
        'X': x, 
        'Y': y
    }
    
    df = pd.DataFrame(frame, columns=frame.keys())
    
    mv_df = calculate_band(df, window_size, sigma)
        
    fig, ax = plt.subplots()
    ax.set_title(title)

    # Draw 'Y' values
    ax.plot(mv_df['X'], mv_df['Y'], 
            label='Y-value')
    
    # Draw Moving Average
    ax.plot(mv_df['X'], mv_df['MA'], 
        label=str(window_size) + ' MA')
    
    ax.fill_between(mv_df['X'], 
                    mv_df['U_band'], 
                    mv_df['L_band'], 
                    facecolor = band_color,
                    alpha = band_alpha)
    
    ax.legend()
    plt.savefig(imgdata, format='png')
    imgdata.seek(0)
    return base64.b64encode(imgdata.buf)
					  
X = np.array(p_x.split(',')).astype('float')
Y = np.array(p_y.split(',')).astype('float')

if p_sigma:
	sigma = p_sigma
else:
	sigma = 2.0
return draw_ma_band_plot_chart(X, Y, p_title, p_window_size, sigma, p_option)
$BODY$;