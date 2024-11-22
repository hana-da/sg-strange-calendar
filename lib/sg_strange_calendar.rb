# frozen_string_literal: true

require 'date'

class SgStrangeCalendar
  DAY_CELLS = 37

  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

  HEADER = {
    month: Date::ABBR_MONTHNAMES,
    day:   Date::DAYNAMES.map { _1[0, 2] }.cycle.first(DAY_CELLS)
  }.freeze

  CONVERTER_AND_ROW_FORMAT = {
    horizontal: [:itself,    "%-4s#{'%3s' * DAY_CELLS}"],
    vertical:   [:transpose, "%-4s#{'%4s' * 12}"]
  }.freeze

  def initialize(year, today = nil)
    @year = year
    @today = today

    @horizontal_grid = HEADER[:month].zip
    @horizontal_grid[0] = [@year, *HEADER[:day]]

    fill_horizontal_grid_with_marked_days
  end

  def generate(vertical: false)
    direction = vertical ? :vertical : :horizontal

    converter, row_format = CONVERTER_AND_ROW_FORMAT[direction]
    grid = @horizontal_grid.public_send(converter)

    grid.map { |row| (row_format % row).rstrip }.join("\n")
      .sub(/-(\d+) ?/) { "[#{$1}]" }
  end

  private

  def fill_horizontal_grid_with_marked_days
    1.upto(12) do |month|
      start_index = first_wday(month:) + 1

      @horizontal_grid[month][start_index..] = marked_days(month:)
      @horizontal_grid[month][DAY_CELLS] ||= nil # 要素数を揃える
    end
  end

  def marked_days(month:)
    Array(1..end_of(month:)).tap do |days|
      # @todayがある時は当該日を[]で囲む時のマーカーとして負数にしておく
      days[@today.day - 1] *= -1 if @today&.month == month
    end
  end

  def end_of(month:)
    if month == 2 && Date.gregorian_leap?(@year)
      29
    else
      DAYS_IN_MONTH[month]
    end
  end

  # https://ja.wikipedia.org/wiki/ツェラーの公式
  def first_wday(month:)
    year, day = @year, 1
    (year -= 1; month += 12) if month < 3

    c, y = year.divmod(100)
    r = -2 * c + c / 4

    # 土曜日が0になるので、日曜日が0になるように補正
    ((day + (26 * (month + 1)) / 10 + y + y / 4 + r) % 7 + 6) % 7
  end
end
