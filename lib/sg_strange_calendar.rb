# frozen_string_literal: true

require 'date'

class SgStrangeCalendar
  DAY_CELLS = 37

  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

  HEADER = {
    month: Date::ABBR_MONTHNAMES,
    day:   Date::DAYNAMES.map { _1[0, 2] }.cycle.first(DAY_CELLS)
  }.freeze

  def initialize(year, _today = nil)
    @year = year
    @grid = grid_only_header

    fill_grid_with_days
  end

  def generate(vertical: false)
    @grid.map do |row|
      format("%-4s#{'%3s' * (row.size - 1)}\n", *row)
    end.join.chomp
  end

  private

  def grid_only_header
    HEADER[:month].zip.tap { |grid| grid[0] = [@year, *HEADER[:day]] }
  end

  def fill_grid_with_days
    1.upto(12).each do |month|
      # 月初のwdayが欲しいだけなので、本当はDate.newより計算した方が速いはず(が、何も見ずに書けない :<
      start_index = Date.new(@year, month, 1).wday + 1

      end_of_month = DAYS_IN_MONTH[month]
      end_of_month = 29 if month == 2 && Date.gregorian_leap?(@year)

      @grid[month][start_index..] = Array(1..end_of_month)
    end
  end
end
