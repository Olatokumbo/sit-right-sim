import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sit_right_app/models/posture-statistics.model.dart';

class LineChartWidget extends StatefulWidget {
  LineChartWidget(
      {super.key,
      Color? lineColor,
      Color? indicatorLineColor,
      Color? indicatorTouchedLineColor,
      Color? indicatorSpotStrokeColor,
      Color? indicatorTouchedSpotStrokeColor,
      Color? bottomTextColor,
      Color? bottomTouchedTextColor,
      Color? averageLineColor,
      Color? tooltipBgColor,
      Color? tooltipTextColor,
      List<PostureStatistics>? data})
      : lineColor = lineColor ?? Colors.blueAccent,
        indicatorLineColor = indicatorLineColor ?? Colors.yellow,
        indicatorTouchedLineColor = indicatorTouchedLineColor ?? Colors.yellow,
        indicatorSpotStrokeColor = indicatorSpotStrokeColor ?? Colors.yellow,
        indicatorTouchedSpotStrokeColor =
            indicatorTouchedSpotStrokeColor ?? Colors.yellow,
        bottomTextColor = bottomTextColor ?? Colors.yellow,
        bottomTouchedTextColor = bottomTouchedTextColor ?? Colors.yellow,
        averageLineColor = averageLineColor ?? Colors.green,
        tooltipBgColor = Colors.green,
        tooltipTextColor = tooltipTextColor ?? Colors.black,
        data = data ?? [];

  final Color lineColor;
  final Color indicatorLineColor;
  final Color indicatorTouchedLineColor;
  final Color indicatorSpotStrokeColor;
  final Color indicatorTouchedSpotStrokeColor;
  final Color bottomTextColor;
  final Color bottomTouchedTextColor;
  final Color averageLineColor;
  final Color tooltipBgColor;
  final Color tooltipTextColor;
  final List<PostureStatistics> data;

  @override
  State createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  late double touchedValue;

  @override
  void initState() {
    touchedValue = -1;
    super.initState();
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) {
      return Container();
    }
    const style = TextStyle(
      color: Colors.black,
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '';
        break;
      case 1:
        text = 'Upright';
        break;
      case 2:
        text = 'Slouching';
        break;
      case 3:
        text = 'Leaning Left';
        break;
      case 4:
        text = 'Leaning Right';
        break;
      case 5:
        text = 'Leaning Back';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
      fontFamily: 'Digital',
      fontSize: 14 *
          chartWidth /
          500, // Adjust the font size based on the chart width
    );

    // Convert value to minutes and seconds
    int totalSeconds = value.toInt();
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    // Skip some labels based on the total value and chart width
    int skipInterval = 1;

    // Increase the interval based on the chart width
    if (chartWidth < 300) {
      skipInterval =
          300; // Skip to every 5 minutes if chart width is less than 300
    } else if (chartWidth < 500) {
      skipInterval =
          120; // Skip to every 2 minutes if chart width is less than 500
    } else if (chartWidth >= 500) {
      skipInterval = 60; // Skip to every minute
    }

    // Display the label only if the value is a multiple of the interval
    if (totalSeconds % skipInterval != 0) {
      return Container();
    }

    String text =
        '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')} min${minutes > 1 ? "s" : ""}';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 5.0, left: 5.0),
            child: LineChart(
              LineChartData(
                // lineTouchData: LineTouchData(
                //   getTouchedSpotIndicator:
                //       (LineChartBarData barData, List<int> spotIndexes) {
                //     return spotIndexes.map((spotIndex) {
                //       final spot = barData.spots[spotIndex];
                //       if (spot.x == 0 || spot.x == 6) {
                //         return null;
                //       }
                //       return TouchedSpotIndicatorData(
                //         FlLine(
                //           color: widget.indicatorTouchedLineColor,
                //           strokeWidth: 4,
                //         ),
                //         FlDotData(
                //           getDotPainter: (spot, percent, barData, index) {
                //             if (index.isEven) {
                //               return FlDotCirclePainter(
                //                 radius: 8,
                //                 color: Colors.white,
                //                 strokeWidth: 5,
                //                 strokeColor:
                //                     widget.indicatorTouchedSpotStrokeColor,
                //               );
                //             } else {
                //               return FlDotSquarePainter(
                //                 size: 16,
                //                 color: Colors.white,
                //                 strokeWidth: 5,
                //                 strokeColor:
                //                     widget.indicatorTouchedSpotStrokeColor,
                //               );
                //             }
                //           },
                //         ),
                //       );
                //     }).toList();
                //   },
                //   touchTooltipData: LineTouchTooltipData(
                //     getTooltipColor: (touchedSpot) => widget.tooltipBgColor,
                //     getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                //       return touchedBarSpots.map((barSpot) {
                //         final flSpot = barSpot;
                //         if (flSpot.x == 0 || flSpot.x == 6) {
                //           return null;
                //         }

                //         TextAlign textAlign;
                //         switch (flSpot.x.toInt()) {
                //           case 1:
                //             textAlign = TextAlign.left;
                //             break;
                //           case 5:
                //             textAlign = TextAlign.right;
                //             break;
                //           default:
                //             textAlign = TextAlign.center;
                //         }

                //         return LineTooltipItem(
                //           '${widget.weekDays[flSpot.x.toInt()]} \n',
                //           TextStyle(
                //             color: widget.tooltipTextColor,
                //             fontWeight: FontWeight.bold,
                //           ),
                //           children: [
                //             TextSpan(
                //               text: flSpot.y.toString(),
                //               style: TextStyle(
                //                 color: widget.tooltipTextColor,
                //                 fontWeight: FontWeight.w900,
                //               ),
                //             ),
                //             const TextSpan(
                //               text: ' k ',
                //               style: TextStyle(
                //                 fontStyle: FontStyle.italic,
                //                 fontWeight: FontWeight.w900,
                //               ),
                //             ),
                //             const TextSpan(
                //               text: 'calories',
                //               style: TextStyle(
                //                 fontWeight: FontWeight.normal,
                //               ),
                //             ),
                //           ],
                //           textAlign: textAlign,
                //         );
                //       }).toList();
                //     },
                //   ),
                //   touchCallback:
                //       (FlTouchEvent event, LineTouchResponse? lineTouch) {
                //     if (!event.isInterestedForInteractions ||
                //         lineTouch == null ||
                //         lineTouch.lineBarSpots == null) {
                //       setState(() {
                //         touchedValue = -1;
                //       });
                //       return;
                //     }
                //     final value = lineTouch.lineBarSpots![0].x;

                //     if (value == 0 || value == 6) {
                //       setState(() {
                //         touchedValue = -1;
                //       });
                //       return;
                //     }

                //     setState(() {
                //       touchedValue = value;
                //     });
                //   },
                // ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 1,
                      color: widget.averageLineColor,
                      strokeWidth: 3,
                      dashArray: [20, 10],
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    isStepLineChart: true,
                    spots: widget.data.map((e) {
                      // Calculate the difference in seconds between startTime and endTime
                      var timeDifferenceInSeconds = e.endTime
                          .difference(
                              widget.data[0]?.startTime ?? DateTime.now())
                          .inSeconds
                          .toDouble();
                      return FlSpot(timeDifferenceInSeconds, e.value);
                    }).toList(),
                    isCurved: true,
                    barWidth: 4,
                    color: widget.lineColor,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          widget.lineColor.withOpacity(0.5),
                          widget.lineColor.withOpacity(0),
                        ],
                        stops: const [0.5, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      spotsLine: BarAreaSpotsLine(
                        show: true,
                        flLineStyle: FlLine(
                          color: widget.indicatorLineColor,
                          strokeWidth: 2,
                        ),
                        checkToShowSpotLine: (spot) {
                          if (spot.x == 0 || spot.x == 6) {
                            return false;
                          }

                          return true;
                        },
                      ),
                    ),
                    // dotData: FlDotData(
                    //   show: true,
                    //   getDotPainter: (spot, percent, barData, index) {
                    //     if (index.isEven) {
                    //       return FlDotCirclePainter(
                    //         radius: 6,
                    //         color: Colors.white,
                    //         strokeWidth: 3,
                    //         strokeColor: widget.indicatorSpotStrokeColor,
                    //       );
                    //     } else {
                    //       return FlDotSquarePainter(
                    //         size: 12,
                    //         color: Colors.white,
                    //         strokeWidth: 3,
                    //         strokeColor: widget.indicatorSpotStrokeColor,
                    //       );
                    //     }
                    //   },
                    //   checkToShowDot: (spot, barData) {
                    //     return spot.x != 0 && spot.x != 6;
                    //   },
                    // ),
                  ),
                ],
                minY: 0,
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black45),
                ),
                // gridData: FlGridData(
                //   show: true,
                //   drawHorizontalLine: true,
                //   drawVerticalLine: true,
                //   checkToShowHorizontalLine: (value) => value % 1 == 0,
                //   checkToShowVerticalLine: (value) => value % 1 == 0,
                //   getDrawingHorizontalLine: (value) {
                //     if (value == 0) {
                //       return const FlLine(
                //         color: Colors.orange,
                //         strokeWidth: 2,
                //       );
                //     } else {
                //       return const FlLine(
                //         color: Colors.amber,
                //         strokeWidth: 0.5,
                //       );
                //     }
                //   },
                //   getDrawingVerticalLine: (value) {
                //     if (value == 0) {
                //       return const FlLine(
                //         color: Colors.redAccent,
                //         strokeWidth: 10,
                //       );
                //     } else {
                //       return const FlLine(
                //         color: Colors.black12,
                //         strokeWidth: 0.5,
                //       );
                //     }
                //   },
                // ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: leftTitleWidgets,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return bottomTitleWidgets(value, meta, 500);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
