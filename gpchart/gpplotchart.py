"""GPChart Library

@author cbjazz
"""
import matplotlib.pyplot as plt
import numpy as np

from gpchart import GpdbChart

class GpdbPlotChart(GpdbChart):
    """
    This class makes basic plot (scatter or line) chart.
    """

    def __init__(self, title, options):
        """
        Parameters
        ----------
        title : str
            Chart title
        options : str
            Style options with json format
        """
        GpdbChart.__init__(self, title, options)
        self.fig, self.ax = plt.subplots()

    def draw_chart(self, x, y, legend, sequence):
        """This draws basic plot (line or scatter) chart.
        Args (x, y, legend and sequence) should  have same length.

        Parameters
        ----------
        x : list
            x axis data
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

        self.ax.set_title(self.title)

        # Set legend sequence
        if sequence.size != 0:
            seq = []
            for i in range(u_legend_cnt):
                seq.append(sequence[np.where(legend == u_legend[i])][0])
            sorted_seq_index = np.argsort(seq)
        else:
            seq = np.arange(u_legend_cnt)
            sorted_seq_index = np.arange(u_legend_cnt)

        # Bind data
        for i in sorted_seq_index:
            sub_x = x[np.where(legend == u_legend[i])]
            sub_y = y[np.where(legend == u_legend[i])]
            self.ax.plot(sub_x, sub_y, label=u_legend[i])

        self.ax.legend()

if __name__ == '__main__':
    OPTIONS = '''{
        "style":"bmh",
        "figure.figsize": [12.0, 6.0],
        "legend.loc":"upper right",
        "lines.marker":"o",
        "axes.color_map":"PuOr",
        "axes.color_alpha":0.7
    }'''
    chart = GpdbPlotChart('test', OPTIONS)
    chart.draw_chart([1, 2, 3], [1, 2, 3], ['A', 'A', 'A'], [1, 1, 1])
    chart.save_file('test_plot.png')
