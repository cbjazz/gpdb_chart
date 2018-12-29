"""GPChart Library

@author cbjazz
"""
import matplotlib.pyplot as plt
import numpy as np

from gpchart import GpdbChart
from gpchart import *

class GpdbBoxChart(GpdbChart):
    """
    This class generate basic plot (scatter or line) chart.
    """
    fig = None
    ax = None
    whiskers = 1.5

    def __init__(self, title, options, whiskers = 1.5):
        """
        Parameters
        ----------
        title : str
            Chart title
        options : str
            Style options with json format
        whiskers : float, optional (default = 1.5)
            Whiskers length of box
        """
        GpdbChart.__init__(self, title, options)
        self.fig, self.ax = plt.subplots()
        self.whiskers = whiskers

    def draw_chart(self, x, y, legend, sequence):
        """This draws basic plot (line or scatter) chart.
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
            color_map = option_dict[OPT_COLOR_PALLETE]
        elif OPT_COLOR_MAP in self.option_dict.keys():
            color_map = self.set_color_map(
                            self.option_dict[OPT_COLOR_MAP],
                            alpha,
                            u_legend_cnt)
        else:
            color_map = set_color_map('hsv', alpha, u_legend_cnt)

        self.ax.set_title(self.title)

        # Set legend sequence
        if sequence.size != 0:
            seq = []
            for i in range(u_legend_cnt):
                seq.append(sequence[np.where(legend==u_legend[i])][0])
            sorted_seq_index = np.argsort(seq)
        else:
            seq = np.arange(u_legend_cnt)
            sorted_seq_index = np.arange(u_legend_cnt)

        # Bind data
        data = []
        sorted_legend = []
        if u_legend_cnt > 1:
            for i in sorted_seq_index:
                sub_y = y[np.where(legend==u_legend[i])]
                data.append(sub_y)
                sorted_legend.append(u_legend[i])
        else:
            data.append(y)
            sorted_legend.append(self.title)

        bp = self.ax.boxplot(data,
                        patch_artist=True,
                        whis=self.whiskers)

        # fill the box with color map
        for i in range(u_legend_cnt):
            box = bp['boxes'][i]
            box.set_facecolor(color_map[i])

        self.ax.legend()

if __name__ == '__main__':
    options = '''{
        "style":"bmh",
        "figure.figsize": [12.0, 6.0],
        "legend.loc":"upper right",
        "axes.color_map":"PuOr",
        "axes.color_alpha":0.7
    }'''
    chart = GpdbBoxChart('test', options, 1.0)
    chart.draw_chart([1,2,3], [1,2,3], ['A', 'A', 'A'], [1,1,1])
    chart.save_file('test_box.png')
