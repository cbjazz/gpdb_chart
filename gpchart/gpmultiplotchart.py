"""GPChart Library

@author cbjazz
"""
import matplotlib.pyplot as plt
import numpy as np

from gpchart import GpdbChart
from gpchart import OPT_COLOR_ALPHA
from gpchart import OPT_COLOR_PALLETE
from gpchart import OPT_COLOR_MAP


class GpdbMultiPlotChart(GpdbChart):
    """
    This class makes multi plot chart.
    """
    is_vertical = False

    def __init__(self, title, options, is_vertical=False):
        """
        Parameters
        ----------
        title : str
            Chart title
        options : str
            Style options with json format
        is_vertical : boolean, optional (default = False)
            Vertial aligned subplots
        """
        GpdbChart.__init__(self, title, options)
        self.is_vertical = is_vertical

    def draw_chart(self, x, y, legend, sequence):
        """This draws multi plot (line or scatter) chart.
        Args (x, y, legend and sequence) should  have same length.

        Parameters
        ----------
        x : None
            x values do not used in box float.
        y : list
            y axis data
        legend : list
            legend values
        sequence: list
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

        # Set color map
        color_map = []
        alpha = 1.0
        if OPT_COLOR_ALPHA in self.option_dict.keys():
            alpha = self.option_dict[OPT_COLOR_ALPHA]
        if OPT_COLOR_PALLETE in self.option_dict.keys():
            color_map = self.option_dict[OPT_COLOR_PALLETE]
        elif OPT_COLOR_MAP in self.option_dict.keys():
            color_map = self.set_color_map(
                self.option_dict[OPT_COLOR_MAP],
                alpha,
                u_legend_cnt)
        else:
            color_map = self.set_color_map('hsv', alpha, u_legend_cnt)

        # Draw chart and bind data
        if self.is_vertical:
            self.fig, self.ax = plt.subplots(u_legend_cnt, 1)
        else:
            self.fig, self.ax = plt.subplots(1, u_legend_cnt)

        # Set legend sequence
        if sequence.size != 0:
            seq = []
            for i in range(u_legend_cnt):
                seq.append(sequence[np.where(legend == u_legend[i])][0])
            sorted_seq_index = np.argsort(seq)
        else:
            seq = np.arange(u_legend_cnt)
            sorted_seq_index = np.arange(u_legend_cnt)

        y_high_limit = np.max(y)
        y_low_limit = np.min(y)

        x_high_limit = np.max(x)
        x_low_limit = np.min(x)

        # Bind data
        idx = 0
        for i in sorted_seq_index:
            sub_x = x[np.where(legend == u_legend[i])]
            sub_y = y[np.where(legend == u_legend[i])]

            self.ax[idx].set_title(u_legend[i])
            if self.is_vertical:
                self.ax[idx].set_xlim(x_low_limit, x_high_limit)
            else:
                self.ax[idx].set_ylim(y_low_limit, y_high_limit)

            self.ax[idx].plot(sub_x, sub_y,
                              label=u_legend[i], color=color_map[idx])

            if idx != 0:
                if self.is_vertical == False:
                    # Only draw y-label to left axes in case of horizontal.
                    self.ax[idx].set_yticklabels([])
            if idx != u_legend_cnt - 1:
                if self.is_vertical:
                    # Only draw x-label to bottom axes in case of vertical.
                    self.ax[idx].set_xticklabels([])
            idx = idx + 1

if __name__ == '__main__':
    OPTIONS = '''{
        "style":"bmh",
        "figure.figsize": [12.0, 6.0],
        "legend.loc":"upper right",
        "axes.color_map":"hsv",
        "axes.color_alpha":0.7,
        "figure.subplot.wspace":0.1,
        "figure.subplot.hspace":0.1
    }'''
    chart = GpdbMultiPlotChart('test', OPTIONS, False)
    chart.draw_chart([1, 2, 3, 4, 5, 1, 2, 3, 4],
                     [1, 2, 3, 4, 5, 6, 4, 2, 6],
                     ['A', 'A', 'A', 'A', 'A', 'B', 'B', 'B', 'B'],
                     [1, 1, 1, 1, 1, 2, 2, 2, 2])
    chart.save_file("multi_bar_chart.png")
