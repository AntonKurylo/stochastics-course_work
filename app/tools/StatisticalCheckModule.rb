module StatisticalCheckModule
  def mean(array)
    array.sum / array.length.to_f
  end

  def dispersion(array)
    mean = mean(array)
    sq_mean = array.map { |i| i * i }.sum

    Math.sqrt(1.0 / (array.length - 1) * (sq_mean - array.length * (mean ** 2)))
  end

  def mode(array)
    hash = Hash.new

    array.each do |i|
      j = i.round(3)
      if hash.key?(j)
        tmp_value = hash.dig(j)
        hash.store(j, tmp_value + 1)
      else
        hash.store(j, 1)
      end
    end

    hash.sort { |a, b| b[1] <=> a[1] }.first[0]
  end
end
