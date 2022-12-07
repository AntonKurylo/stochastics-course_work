module SeriesModule
  def p_k_frequency(bottom_limit, upper_limit, rand_array, n_g)
    series = Hash.new
    step = (upper_limit - bottom_limit) / n_g.to_f

    bottom_limit.step(upper_limit, step) do |i|
      break if i == upper_limit

      v_k = 0
      from = i
      to = i + step

      rand_array.each do |e|
        if e > from and e < to # if e >= from and e <= to
          v_k += 1
        end
      end

      p_k = v_k / rand_array.length.to_f
      series.store("series_#{series.length + 1}", [[from, to], p_k])
    end

    series
  end

  def statistical_estimates(series_hash)
    estimates = Hash.new

    series_hash.each_value do |value|
      from = value[0][0]
      to = value[0][1]
      p_k = value[1]

      ro_k = p_k / (to - from)
      estimates.store("estimates_#{estimates.length + 1}", [[from, to], ro_k])
    end

    estimates
  end
end
