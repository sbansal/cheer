export function seriesBarsPlugin({ xLabels=[], gap=0.2 }={}) {

  // We want X Axis labels to be center aligned to it's barchart group.
  // To achieve this, we increase the visible range then draw each bar 50% to the left.
  const offset = 1;

  function getRangeX (u, dataMin, dataMax) {

    const absMin = u.data[0][0];
    const absMax = u.data[0][u.data[0].length-1];

    const min = Math.max(dataMin, absMin) - offset;
    const max = Math.min(dataMax, absMax) + offset;

    return [min, max];
  }

  function getValueX (u, v) {
    return xLabels[v];
  }

  function getAxisLabels (u, vals, space) {
    return vals.map((v,i) => (xLabels[v]) || "");
  }

  function drawPath(u, sidx, i0, i1) {
    const s      = u.series[sidx];
    const xdata  = u.data[0];
    const ydata  = u.data[sidx];
    const scaleX = 'x';
    const scaleY = s.scale;
    const yseriesCount = u.data.length-1;
    const yseriesIdx = (sidx-1);
    const stroke = new Path2D();
    const barWidth = (1 - gap) / yseriesCount;

    for (let i = i0; i <= i1; i++) {

      const xStartPos = xdata[i] + (yseriesIdx * barWidth) + (gap / 2) - (offset / 2);
      const xEndPos = xStartPos + barWidth;
      const x0 = u.valToPos(xStartPos, scaleX, true);
      const x1 = u.valToPos(xEndPos, scaleX, true);
      const y0 = u.valToPos(ydata[i], scaleY, true);
      const y1 = u.valToPos(0, scaleY, true);;
      const width = x1 - x0;
      const height = y1 - y0;

      stroke.rect(x0, y0, width, height);
    }

    const fill  = new Path2D(stroke);

    return {stroke, fill}
  }

  return {
    opts: (u, opts) => {

      Object.assign(opts, {
        cursor: opts.cursor || {},
        scales: opts.scales || {},
        axes  : opts.axes   || []
      })

      if (!opts.series[0].value)
        opts.series[0].value = getValueX;

      opts.series.forEach(series => {
        series.paths = drawPath;
      });

      Object.assign(opts.cursor, {
        points: false,
      });

      opts.scales.x = Object.assign(opts.scales.x || {}, {
        time: false,
        range: getRangeX,
        distr: 2
      });

      opts.axes[0] = Object.assign(opts.axes[0] || {}, {
        values: getAxisLabels
      });
    }
  }
}