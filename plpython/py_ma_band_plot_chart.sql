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
def calculateBand(df, window_size=1, sigma=2.0):
    df['MA'] = df['Y'].rolling(window=window_size).mean()
    df['STD'] = df['Y'].rolling(window=window_size).std()
    df['U_band'] = df['MA'] + (df['STD'] * sigma)
    df['L_band'] = df['MA'] - (df['STD'] * sigma)
    return df
	
def drawMABandPlotChart(X, Y, title, window_size, sigma, options):
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
            color_norm = colors.Normalize(vmin=0, vmax=3)
            scalar_map = cmx.ScalarMappable(norm=color_norm, cmap = options.getOption('color.map'))       
            for i in range(3):
                color_map.append(scalar_map.to_rgba(i))
    """
    Set axes options
    """
    if options.isExist('axes'):
        axes_alpha = options.getOption('axes.alpha')
        axes_format = options.getOption('axes.format')
        axes_markersize = options.getOption('axes.markersize')
        axes_linewidth = options.getOption('axes.linewidth')
        
    """
    Set band options
    """
    if options.isExist('band'):
        band_fill_color = options.getOption('band.fill_color')
        band_fill_alpha = options.getOption('band.fill_alpha')
        
    frame = {
        'X': X, 
        'Y': Y
    }
    
    df = pd.DataFrame(frame, columns=frame.keys())
    
    mv_df = calculateBand(df, window_size, sigma)

    imgdata = StringIO.StringIO()
    fig, ax = plt.subplots()
    fig.set_size_inches(fig_size_x, fig_size_y)  
    ax.set_title(title)
        
    ax.fill_between(mv_df['X'], 
                    mv_df['U_band'], 
                    mv_df['L_band'], 
                    alpha=band_fill_alpha,
                    color=band_fill_color)

    # Draw 'Y' values
    ax.plot(mv_df['X'], mv_df['Y'], 
            axes_format,
            lw=axes_linewidth, 
            alpha=axes_alpha,
            color=color_map[0],
            label='Y-value')
    
    # Draw Moving Average
    ax.plot(mv_df['X'], mv_df['MA'], 
        axes_format,
        lw=axes_linewidth, 
        alpha=axes_alpha,
        color=color_map[1],
        label=str(window_size) + ' MA')
    
    ax.legend(loc = legend_loc, fontsize='small')
    plt.savefig(imgdata, format='png')
    imgdata.seek(0)
    return base64.b64encode(imgdata.buf)
					  
X = np.array(p_x.split(',')).astype('float')
Y = np.array(p_y.split(',')).astype('float')
title = p_title

if p_option:
	opt = MyChartOption(p_option)
else:
	opt = None

if p_sigma:
	sigma = p_sigma
else:
	sigma = 2.0
return drawMABandPlotChart(X, Y, title, p_window_size, sigma, opt)
$BODY$;