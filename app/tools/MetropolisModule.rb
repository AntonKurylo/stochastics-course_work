require_relative "../../app/tools/VonMisesDistributionModule"
include VonMisesDistribution

module MetropolisModule

  def von_mises_metropolis(bottom_limit, upper_limit, k, m, n_s)
    # генерування ВВ методом Метрополіса
    metropolis = Array.new # масив випадкових величин
    bessel_0 = VonMisesDistribution.modified_bessel_function(k, 0) # знаходження модифікованої функції Беселя першого роду порядку 0
    x_0 = bottom_limit + (upper_limit - bottom_limit) * rand # випадкове значення x_0 з якого стартує алгоритм
    del = (upper_limit - bottom_limit) / 3 # розрахунок дельта

    n_s.to_i.times do
      x = x_0 + (-1 + 2 * rand) * del # випадкове значення x

      if x >= bottom_limit and x <= upper_limit # x > bottom_limit and x < upper_limit
        a = VonMisesDistribution.von_mises_distribution(x, m, k, bessel_0) / VonMisesDistribution.von_mises_distribution(x_0, m, k, bessel_0)
      else
        a = 0
      end

      # вибір випадкового значення x_0
      if a >= 1
        x_0 = x
      elsif rand < a
        x_0 = x
      end

      metropolis << x_0 # додаємо x до масиву
    end

    metropolis
  end
end
