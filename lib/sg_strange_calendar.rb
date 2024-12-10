# frozen_string_literal: true

require 'date'

class SgStrangeCalendar
  DAY_CELLS = 37

  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

  HEADER = {
    month: Date::ABBR_MONTHNAMES,
    day:   Date::DAYNAMES.map { _1[0, 2] }.cycle.first(DAY_CELLS)
  }.freeze

  CONVERTER_AND_ROW_FORMATER = {
    horizontal: [:itself,    ->(row) { ("%-4s#{'%3s' * DAY_CELLS}" % row).rstrip }],
    vertical:   [:transpose, ->(row) { ("%-4s#{'%4s' * 12}" % row).rstrip }]
  }.freeze

  def initialize(year, today = nil)
    @year = year
    @today = today
  end

  def generate(vertical: false)
    direction = vertical ? :vertical : :horizontal
    converter, formatter = CONVERTER_AND_ROW_FORMATER[direction]

    horizontal_grid.public_send(converter).map(&formatter).join("\n")
      .sub(/-(\d+) ?/) { "[#{$1}]" }
  end

  private

  def horizontal_grid
    @horizontal_grid ||= HEADER[:month].zip.tap do |grid|
      grid[0] = [@year, *HEADER[:day]]

      1.upto(12) do |month|
        start_index = first_wday(month) + 1

        grid[month][start_index..] = marked_days(month)
        grid[month][DAY_CELLS] ||= nil # 要素数を揃える
      end
    end
  end

  def marked_days(month)
    Array(1.upto(end_of(month))).tap do |days|
      # @todayがある時は当該日を[]で囲む時のマーカーとして負数にしておく
      days[@today.day - 1] *= -1 if @today&.month == month
    end
  end

  def end_of(month)
    if month == 2 && Date.gregorian_leap?(@year)
      29
    else
      DAYS_IN_MONTH[month]
    end
  end

  # https://ja.wikipedia.org/wiki/ツェラーの公式
  def first_wday(m)
    y, d = @year, 1
    (y -= 1; m += 12) if m < 3

    (y + y / 4 - y / 100 + y / 400 + (13 * m + 8) / 5 + d) % 7
  end
end
