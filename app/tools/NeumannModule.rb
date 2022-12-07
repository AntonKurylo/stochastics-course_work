require_relative "../../app/tools/VonMisesDistributionModule"
include VonMisesDistribution

module NeumannModule
  def von_mises_neumann(bottom_limit, upper_limit, k, m, n_s) # генерування ВВ методом Неймана
    neumann = Array.new # масив випадкових величин
    max = VonMisesDistribution.max_von_mises(bottom_limit, upper_limit, k, m, n_s) # знаходження максимального значення функції щілності ймовірності
    bessel_0 = VonMisesDistribution.modified_bessel_function(k, 0) # знаходження модифікованої функції Беселя першого роду порядку 0

    n_s.to_i.times do
      # проходимо цикл для кожної точки, де n_s - кількість точок
      while true do
        # генеруємо до тих пір поки точка не потрапила до графіку
        x = rand * (upper_limit - bottom_limit) + bottom_limit # генерація координати x
        y = rand * max # генерація координати y

        if VonMisesDistribution.von_mises_distribution(x, m, k, bessel_0) > y
          neumann << x # точка потрапила до графіку, додаємо х до масиву
          break
        end
      end
    end

    neumann
  end
end
