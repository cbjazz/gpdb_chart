"""GPChart Library

@author cbjazz
"""
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from gpchart import GpdbChart
from gpchart import OPT_BAND_COLOR
from gpchart import OPT_BAND_COLOR_ALPHA

class GpdbMABandPlotChart(GpdbChart):
    """
    This class makes plot chart with the band for moving average.
    """
    window_size = 1
    sigma = 2.0

    def __init__(self, title, options, window_size=1, sigma=2.0):
        """
        Parameters
        ----------
        title : str
            Chart title
        options : str
            Style options with json format
        window_size : int
            Window size for moving average
        sigma : float
            Sigma value for bandwidth based on standard deviation
        """
        GpdbChart.__init__(self, title, options)
        self.window_size = window_size
        self.sigma = sigma

    def _calculate_band(self, df):
        """ This calculates moving average and band width.

        Parameters
        ----------
        df : dataframe
            dataframe for X and Y data

        Return
        ----------
        dataframe: dataframe added MA, STD, upper bound and lower bound
        """
        df['MA'] = df['Y'].rolling(window=self.window_size).mean()
        df['STD'] = df['Y'].rolling(window=self.window_size).std()
        df['U_band'] = df['MA'] + (df['STD'] * self.sigma)
        df['L_band'] = df['MA'] - (df['STD'] * self.sigma)
        return df

    def _get_bar_width(self, x_axis_cnt, legend_cnt):
        """ This calculates bar width.

        Parameters
        ----------
        x_axis_cnt : int
            The number of x values
        legend_cnt : int
            The number of legends

        Return
        ----------
        float: bar width
        """
        if (OPT_BAR_WIDTH in self.option_dict.keys()):
            axes_barwidth = self.option_dict[OPT_BAR_WIDTH]
        else:
            axes_barwidth = 1 / (x_axis_cnt * legend_cnt)

        return axes_barwidth

    def draw_chart(self, x, y, legend, sequence=None):
        """This draws bar chart.
        Args (x, y, legend and sequence) should  have same length.

        Parameters
        ----------
        x : list
            x axis data.
        y : list
            y axis data
        legend : list
            legend values
        sequence: list, optional
            Legends are sorted by sequence number ascendingly.
        """
        # We use numpy array for futher compatibility.
        x = np.array(x)
        y = np.array(y)
        legend = np.array(legend)
        sequence = np.array(sequence)

        if legend.size != 0:
            u_legend = np.unique(legend)
            u_legend_cnt = len(u_legend)
        else:
            u_legend = np.array([self.title])
            u_legend_cnt = 1

        # Set chart sytle
        self._set_style()
        self._set_mpl_option()
        self._set_cycler(u_legend_cnt)

        # Set customized options for band
        band_color = 'y' # default color of band is yellow
        if (OPT_BAND_COLOR in self.option_dict.keys()):
            band_color = self.option_dict[OPT_BAND_COLOR]

        band_alpha = 0.5
        if (OPT_BAND_COLOR_ALPHA in self.option_dict.keys()):
            band_alpha = self.option_dict[OPT_BAND_COLOR_ALPHA]

        # Calculage ma and band
        frame = {
            'X': x,
            'Y': y
        }
        df = pd.DataFrame(frame, columns=frame.keys())
        mv_df = self._calculate_band(df)

        self.fig, self.ax = plt.subplots()

        self.ax.set_title(self.title)

        # Draw 'Y' values
        self.ax.plot(mv_df['X'], mv_df['Y'],
                label='Y-value')

        # Draw Moving Average
        self.ax.plot(mv_df['X'], mv_df['MA'],
            label=str(self.window_size) + ' MA')

        self.ax.fill_between(mv_df['X'],
                        mv_df['U_band'],
                        mv_df['L_band'],
                        facecolor = band_color,
                        alpha = band_alpha)

        self.ax.legend()


if __name__ == '__main__':
    OPTIONS = '''{
        "style":"bmh",
        "figure.figsize": [12.0, 6.0],
        "legend.loc":"upper right",
        "axes.color_pallete":["#173F5F", "#20639B", "#ED553B", "#3CAEA3", "#F6D55C"],
        "axes.color_alpha":0.7,
        "axes.band_color" : "#F6D55C",
        "axes.band_color_alpha" : 0.3
        }'''
    chart = GpdbMABandPlotChart('test', OPTIONS, 3, 2.0)
    chart.draw_chart([1, 2, 3, 4, 5, 6, 7, 8, 9],
                     [1, 2, 3, 4, 5, 6, 4, 2, 6],
                     ['A', 'A', 'A', 'A', 'A', 'A', 'A', 'A', 'A'])
    chart.save_file("ma_band_plot_chart.png")
