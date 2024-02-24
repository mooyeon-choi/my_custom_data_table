import 'package:flutter/material.dart';

enum ColumnSize { S, M, L }

@immutable
class MyCustomDataColumn extends DataColumn {
  /// Creates the configuration for a column of a [DataTable].

  const MyCustomDataColumn(
      {required super.label,
      required this.value,
      super.tooltip,
      super.numeric = false,
      super.onSort,
      this.size = ColumnSize.M,
      this.fixedWidth,
      this.color});

  /// Column sizes are determined based on available width by distributing it
  /// to individual columns accounting for their relative sizes (see [ColumnSize])
  final ColumnSize size;

  /// Defines absolute width of the column in pixel (as opposed to relative size used by default).
  /// Warning, if the width happens to be larger than available total width other
  /// columns can be clipped
  final double? fixedWidth;

  final String value;

  final Color? color;
}

class MyCustomDataRow extends DataRow {
  //DataRow2.fromDataRow(DataRow row) : this.cells = row.cells;

  /// Creates the configuration for a row of a [DataTable].
  ///
  /// The [cells] argument must not be null.
  const MyCustomDataRow(
      {super.key,
      super.selected = false,
      super.onSelectChanged,
      super.color,
      this.decoration,
      required super.cells,
      this.specificRowHeight,
      this.onTap,
      this.onDoubleTap,
      super.onLongPress,
      this.onSecondaryTap,
      this.onSecondaryTapDown});

  MyCustomDataRow.byIndex(
      {super.index,
      super.selected = false,
      super.onSelectChanged,
      super.color,
      this.decoration,
      required super.cells,
      this.specificRowHeight,
      this.onTap,
      this.onDoubleTap,
      super.onLongPress,
      this.onSecondaryTap,
      this.onSecondaryTapDown})
      : super.byIndex();

  /// Clone row, if non null values are provided - override the corresponding fields
  MyCustomDataRow clone({
    LocalKey? key,
    bool? selected,
    ValueChanged<bool?>? onSelectChanged,
    MaterialStateProperty<Color?>? color,
    Decoration? decoration,
    List<DataCell>? cells,
    double? specificRowHeight,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapCallback? onSecondaryTap,
    GestureTapDownCallback? onSecondaryTapDown,
  }) {
    return MyCustomDataRow(
      key: key ?? this.key,
      selected: selected ?? this.selected,
      onSelectChanged: onSelectChanged ?? this.onSelectChanged,
      color: color ?? this.color,
      decoration: decoration ?? this.decoration,
      cells: cells ?? this.cells,
      specificRowHeight: specificRowHeight ?? this.specificRowHeight,
      onTap: onTap ?? this.onTap,
      onDoubleTap: onDoubleTap ?? this.onDoubleTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onSecondaryTap: onSecondaryTap ?? this.onSecondaryTap,
      onSecondaryTapDown: onSecondaryTapDown ?? this.onSecondaryTapDown,
    );
  }

  /// Decoration to nbe applied to the given row. When applied, it [DataTable2.dividerThickness]
  /// won't take effect
  final Decoration? decoration;

  /// Specific row height, which will be used only if provided.
  /// If not provided, dataRowHeight will be applied.
  final double? specificRowHeight;

  /// Row tap handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onTap;

  /// Row right click handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onSecondaryTap;

  /// Row right mouse down handler, won't be called if tapped cell has any tap event handlers
  final GestureTapDownCallback? onSecondaryTapDown;

  /// Row double tap handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onDoubleTap;

// /// Row long press handler, won't be called if tapped cell has any tap event handlers
// final GestureLongPressCallback? onLongPress;
}

class CustomDataTable extends DataTable {
  CustomDataTable({
    super.key,
    required super.columns,
    super.sortColumnIndex,
    super.sortAscending = true,
    super.onSelectAll,
    super.decoration,
    super.dataRowColor,
    this.dataRowHeight,
    super.dataTextStyle,
    super.headingRowColor,
    this.fixedColumnsColor,
    this.fixedCornerColor,
    super.headingRowHeight,
    super.headingTextStyle,
    this.headingCheckboxTheme,
    this.datarowCheckboxTheme,
    super.horizontalMargin,
    super.checkboxHorizontalMargin,
    this.checkboxAlignment = Alignment.center,
    this.bottomMargin,
    super.columnSpacing,
    super.showCheckboxColumn = true,
    super.showBottomBorder = false,
    super.dividerThickness,
    super.clipBehavior,
    this.minWidth,
    this.scrollController,
    this.horizontalScrollController,
    this.isVerticalScrollBarVisible,
    this.isHorizontalScrollBarVisible,
    this.empty,
    this.border,
    this.smRatio = 0.67,
    this.fixedTopRows = 1,
    this.fixedLeftColumns = 0,
    this.lmRatio = 1.2,
    this.sortArrowAnimationDuration = const Duration(milliseconds: 150),
    this.sortArrowIcon = Icons.arrow_upward,
    this.sortArrowBuilder,
    this.headingRowDecoration,
    required super.rows,
    this.data,
  })  : assert(fixedLeftColumns >= 0),
        assert(fixedTopRows >= 0);

  static final LocalKey _headingRowKey = UniqueKey();

  void _handleSelectAll(bool? checked, bool someChecked) {
    // If some checkboxes are checked, all checkboxes are selected. Otherwise,
    // use the new checked value but default to false if it's null.
    final bool effectiveChecked = someChecked || (checked ?? false);
    if (onSelectAll != null) {
      onSelectAll!(effectiveChecked);
    } else {
      for (final DataRow row in rows) {
        if (row.onSelectChanged != null && row.selected != effectiveChecked) {
          row.onSelectChanged!(effectiveChecked);
        }
      }
    }
  }

  /// The default height of the heading row.
  static const double _headingRowHeight = 56.0;

  /// The default horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  static const double _horizontalMargin = 24.0;

  /// The default horizontal margin between the contents of each data column.
  static const double _columnSpacing = 56.0;

  /// The default padding between the heading content and sort arrow.
  static const double _sortArrowPadding = 2.0;

  /// The default divider thickness.
  static const double _dividerThickness = 1.0;

  /// When changing sort direction an arrow icon in the header is rotated clockwise.
  /// The value defines the duration of the rotation animation.
  /// If not set, the default animation duration is 150 ms.
  final Duration sortArrowAnimationDuration;

  /// Icon to be displayed when sorting is applied to a column.
  /// If not set, the default icon is [Icons.arrow_upward].
  /// When set always overrides/preceeds default arrow icons.
  final IconData sortArrowIcon;

  /// A builder for the sort arrow widget. Can be used in combination with [sortArrowAlwaysVisible] for a custom
  /// sort arrow behavior. If this is used [sortArrowIcon], [sortArrowAnimationDuration] will be ignored.
  final Widget? Function(bool ascending, bool sorted)? sortArrowBuilder;

  /// If set, the table will stop shrinking below the threshold and provide
  /// horizontal scrolling. Useful for the cases with narrow screens (e.g. portrait phone orientation)
  /// and lots of columns (that get messed with little space)
  final double? minWidth;

  /// Overrides theme of the checkbox that is displayed in the leftmost corner
  /// of the heading (should checkboxes be enabled)
  final CheckboxThemeData? headingCheckboxTheme;

  /// Alignment of the checkbox if it is displayed
  /// Defaults to the [Alignment.center]
  final Alignment checkboxAlignment;

  /// Overrides theme of the checkbox that is displayed in the checkbox column
  /// in each data row (should checkboxes be enabled)
  final CheckboxThemeData? datarowCheckboxTheme;

  /// If set the table will have empty space added after the the last row and allow scroll the
  /// core of the table higher (e.g. if you would like to have iOS navigation UI at the bottom overlapping the table and
  /// have the ability to slightly scroll up the bototm row to avoid the obstruction)
  final double? bottomMargin;

  /// Overrides default [BoxDecoration](bottom border) applied to heading row.
  /// When both [headerRowColor] and this porperty are provided:
  /// - [headingRowDecoration] takes precedence if there're 0 or 1 fixed rows
  /// - [headerRowColor] is applied to fixed top forws starting from the second
  /// When there're both fixed top rows and fixed left columns with [fixedCornerColor] provided,
  /// this decoration overrides top left cornner cell color.
  final BoxDecoration? headingRowDecoration;

  /// The height of each row (excluding the row that contains column headings).
  ///
  /// If null, [DataTableThemeData.dataRowMinHeight] is used. This value defaults
  /// to [kMinInteractiveDimension] to adhere to the Material Design
  /// specifications.
  ///
  /// Note that unlike stock [DataTable] from the SDK there's no capability to define min/max
  /// height of a row, corresponding properties are ingored. This is an implementation tradeoff
  /// making it possible to have performant sticky columns.
  @override
  final double? dataRowHeight;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows vertically scrollable
  final ScrollController? scrollController;

  /// Exposes scroll controller of the SingleChildScrollView that makes data rows horizontally scrollable
  final ScrollController? horizontalScrollController;

  /// Determines whether the vertical scroll bar is visible, for iOS takes value from scrollbarTheme when null
  final bool? isVerticalScrollBarVisible;

  /// Determines whether the horizontal scroll bar is visible, for iOS takes value from scrollbarTheme when null
  final bool? isHorizontalScrollBarVisible;

  /// Placeholder widget which is displayed whenever the data rows are empty.
  /// The widget will be displayed below column
  final Widget? empty;

  /// Set vertical and horizontal borders between cells, as well as outside borders around table.
  @override
  // keep field in order to keep doc
  // ignore: overridden_fields
  final TableBorder? border;

  /// Determines ratio of Small column's width to Medium column's width.
  /// I.e. 0.5 means that Small column is twice narower than Medium column.
  final double smRatio;

  /// Determines ratio of Large column's width to Medium column's width.
  /// I.e. 2.0 means that Large column is twice wider than Medium column.
  final double lmRatio;

  /// The number of sticky rows fixed at the top of the table.
  /// The heading row is counted/included.
  /// By defult the value is 1 which means header row is fixed.
  /// Set to 0 in order to unstick the header,
  /// set to >1 in order to fix data rows
  /// (i.e. in order to fix both header and the first data row use value of 2)
  final int fixedTopRows;

  /// Number of sticky columns fixed at the left side of the table.
  /// Check box column (if enabled) is also counted
  final int fixedLeftColumns;

  /// Backgound color of the sticky columns fixed via [fixedLeftColumns].
  /// Note: unlike data rows which can change their colors depending on material state (e.g. selected, hovered)
  /// this color is static and doesn't repond to state change
  /// Note: to change background color of fixed data rows use [DataTable2.headingRowColor]
  final Color? fixedColumnsColor;

  /// Backgound color of the top left corner which is fixed whenere both [fixedTopRows]
  /// and [fixedLeftColumns] are greater than 0
  /// Note: unlike data rows which can change their colors depending on material state (e.g. selected, hovered)
  /// this color is static and doesn't repond to state change
  /// Note: to change background color of fixed data rows use [DataTable2.headingRowColor]
  final Color? fixedCornerColor;

  /// The data to show in each row (excluding the header).
  final List<Map<String, dynamic>>? data;

  (double, double) getMinMaxRowHeight(DataTableThemeData dataTableTheme) {
    final double effectiveDataRowMinHeight = dataRowHeight ??
        dataTableTheme.dataRowMinHeight ??
        kMinInteractiveDimension;
    // Reverting min/max csupport to single row height value in order not to have troubles
    // with sticky column cells
    // https://github.com/maxim-saplin/data_table_2/issues/191
    // final double effectiveDataRowMaxHeight = dataRowMaxHeight ??
    //     dataTableTheme.dataRowMaxHeight ??
    //     dataTableTheme.dataRowMaxHeight ??
    //     kMinInteractiveDimension;

    return (effectiveDataRowMinHeight, effectiveDataRowMinHeight);
  }

  Widget _buildCheckbox(
      {required BuildContext context,
      required bool? checked,
      required VoidCallback? onRowTap,
      required ValueChanged<bool?>? onCheckboxChanged,
      required MaterialStateProperty<Color?>? overlayColor,
      required CheckboxThemeData? checkboxTheme,
      required bool tristate,
      required double? rowHeight}) {
    final DataTableThemeData dataTableTheme = DataTableTheme.of(context);

    final double effectiveHorizontalMargin = horizontalMargin ??
        dataTableTheme.horizontalMargin ??
        _horizontalMargin;

    final (effectiveDataRowMinHeight, effectiveDataRowMaxHeight) =
        getMinMaxRowHeight(dataTableTheme);

    Widget wrapInContainer(Widget child) => Container(
        alignment: checkboxAlignment,
        constraints: BoxConstraints(
            minHeight: rowHeight ?? effectiveDataRowMinHeight,
            maxHeight: rowHeight ?? effectiveDataRowMaxHeight),
        padding: EdgeInsetsDirectional.only(
          start: checkboxHorizontalMargin ?? effectiveHorizontalMargin,
          end: (checkboxHorizontalMargin ?? effectiveHorizontalMargin) / 2.0,
        ),
        child: child);

    Widget contents = Semantics(
      container: true,
      child: wrapInContainer(
        Theme(
            data: ThemeData(checkboxTheme: checkboxTheme),
            child: Checkbox(
              value: checked,
              onChanged: onCheckboxChanged,
              tristate: tristate,
            )),
      ),
    );
    if (onRowTap != null) {
      contents = TableRowInkWell(
        onTap: onRowTap,
        overlayColor: overlayColor,
        child: contents,
      );
    }

    return contents;
  }
}

class MyCustomDataTable extends StatelessWidget {
  const MyCustomDataTable({
    Key? key,
    required this.columns,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.decoration,
    this.dataRowColor,
    this.dataRowHeight,
    this.dataTextStyle,
    this.headingRowColor,
    this.fixedColumnsColor,
    this.fixedCornerColor,
    this.headingRowHeight,
    this.headingTextStyle,
    this.headingCheckboxTheme,
    this.datarowCheckboxTheme,
    this.horizontalMargin,
    this.checkboxHorizontalMargin,
    this.checkboxAlignment = Alignment.center,
    this.bottomMargin,
    this.columnSpacing,
    this.showCheckboxColumn = true,
    this.showBottomBorder = false,
    this.dividerThickness,
    this.minWidth,
    this.scrollController,
    this.horizontalScrollController,
    this.data,
  });

  final List<MyCustomDataColumn> columns;
  final int? sortColumnIndex;
  final bool sortAscending;
  final ValueSetter<bool?>? onSelectAll;
  final Decoration? decoration;
  final MaterialStateProperty<Color?>? dataRowColor;
  final double? dataRowHeight;
  final TextStyle? dataTextStyle;
  final MaterialStateProperty<Color?>? headingRowColor;
  final Color? fixedColumnsColor;
  final Color? fixedCornerColor;
  final double? headingRowHeight;
  final TextStyle? headingTextStyle;
  final CheckboxThemeData? headingCheckboxTheme;
  final CheckboxThemeData? datarowCheckboxTheme;
  final double? horizontalMargin;
  final double? checkboxHorizontalMargin;
  final Alignment checkboxAlignment;
  final double? bottomMargin;
  final double? columnSpacing;
  final bool showCheckboxColumn;
  final bool showBottomBorder;
  final double? dividerThickness;
  final double? minWidth;
  final ScrollController? scrollController;
  final ScrollController? horizontalScrollController;
  final List<Map<String, dynamic>>? data;

  @override
  Widget build(BuildContext context) {
    final List<MyCustomDataRow> rows = (data != null
        ? data!
            .map((element) => MyCustomDataRow(
                cells: columns
                    .map((e) => DataCell(Text(element[e.value].toString())))
                    .toList()))
            .toList()
        : List.empty());

    return CustomDataTable(
      columns: columns,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      onSelectAll: onSelectAll,
      decoration: decoration,
      dataRowColor: dataRowColor,
      dataRowHeight: dataRowHeight,
      dataTextStyle: dataTextStyle,
      headingRowColor: headingRowColor,
      fixedColumnsColor: fixedColumnsColor,
      fixedCornerColor: fixedCornerColor,
      headingRowHeight: headingRowHeight,
      headingTextStyle: headingTextStyle,
      headingCheckboxTheme: headingCheckboxTheme,
      datarowCheckboxTheme: datarowCheckboxTheme,
      horizontalMargin: horizontalMargin,
      checkboxHorizontalMargin: checkboxHorizontalMargin,
      checkboxAlignment: checkboxAlignment,
      bottomMargin: bottomMargin,
      columnSpacing: columnSpacing,
      showCheckboxColumn: showCheckboxColumn,
      showBottomBorder: showBottomBorder,
      dividerThickness: dividerThickness,
      minWidth: minWidth,
      scrollController: scrollController,
      horizontalScrollController: horizontalScrollController,
      rows: rows,
      data: data,
    );
  }
}
