module VonMisesDistribution

  def von_mises_distribution(x, m, k, bessel_0) # функція щільності ймовірності
    Math.exp(k * Math.cos(x - m)) / (2 * Math::PI * bessel_0)
  end

  def modified_bessel_function(k, n) # модифікована функція Беселя першого роду порядку k
    sum = 0.0
    step = 0.00001
    bottom_limit = 0.0
    upper_limit = Math::PI

    bottom_limit.step(upper_limit, step) do |i| # обчислення інтегралу методом середніх прямокутників
      break if i == upper_limit

      middle_point = i + step / 2
      sum += Math.exp(k * Math.cos(middle_point)) * Math.cos(n * middle_point)
    end

    (upper_limit - bottom_limit) * (sum / Math::PI) / ((upper_limit - bottom_limit) / step)
  end

  def max_von_mises(bottom_limit, upper_limit, k, m, n_s) # максимальне значення функції щільності ймовірності
    max = Float::MIN
    step = (upper_limit - bottom_limit) / n_s.to_f
    bessel_0 = modified_bessel_function(k, 0)

    bottom_limit.step(upper_limit, step) do |i|
      temp = von_mises_distribution(i, m, k, bessel_0)

      if temp > max
        max = temp
      end
    end

    max
  end

  def von_mises_cdf(bottom_limit, upper_limit, m, k, n_s) # координати для графіку функції щільності ймовірності розподілу
    step = (upper_limit - bottom_limit) / n_s.to_f
    bessel_0 = modified_bessel_function(k, 0)
    pdf = Array.new

    bottom_limit.step(upper_limit, step) do |i|
      x = i
      y = von_mises_distribution(x, m, k, bessel_0)
      pdf << [x.round(3), y.round(3)]
    end

    pdf
  end

  def von_mises_dispersion(k) # дисперсія розподілу
    1 - (modified_bessel_function(k, 1) / modified_bessel_function(k, 0))
  end


  def von_mises_approximation(bottom_limit, upper_limit, k, m, n_g) # апроксимація розподілу фон Мізеса
    appromax = Hash.new
    step_i = (upper_limit - bottom_limit) / n_g.to_f
    step_j = 0.00001
    bessel_0 = modified_bessel_function(k, 0)

    bottom_limit.step(upper_limit, step_i) do |i|
      break if i == upper_limit
      sum = 0.0

      i.step(i + step_i, step_j) do |j|
        break if j == i + step_i

        middle_point = j + step_j / 2
        sum += von_mises_distribution(middle_point, m, k, bessel_0)
      end

      po_k = step_i * (sum / step_i) / (step_i / step_j)
      appromax.store("appromax_#{appromax.length + 1}", [[i, i + step_i], po_k])
    end

    appromax
  end

end
