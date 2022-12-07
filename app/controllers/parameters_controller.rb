require_relative "../../app/tools/VonMisesDistributionModule"
require_relative "../../app/tools/NeumannModule"
require_relative "../../app/tools/MetropolisModule"
require_relative "../../app/tools/SeriesModule"
require_relative "../../app/tools/StatisticalCheckModule"
include VonMisesDistribution
include NeumannModule
include MetropolisModule
include SeriesModule
include StatisticalCheckModule

class ParametersController < ApplicationController
  before_action :set_parameter, only: %i[ show edit update destroy ]

  # GET /parameters or /parameters.json
  def index
    @parameters = Parameter.all
  end

  # GET /parameters/1 or /parameters/1.json
  def show
    from = @parameter.from.to_f
    to = @parameter.to.to_f
    m = @parameter.m.to_f
    k = @parameter.k.to_f
    n_s = @parameter.n_s.to_f
    n_g = @parameter.n_g.to_f

    @cdf = von_mises_cdf(from, to, m, k, n_s)
    @p_k = von_mises_approximation(from, to, k, m, n_g)
    @dispersion = VonMisesDistribution.von_mises_dispersion(k)
    @mean = @mode = m

    series_one_neumann_hash = statistics_neumann(from, to, k, m, n_s, n_g)
    @series_one_neumann = series_one_neumann_hash.dig(:series)
    @dispersion_one_neumann = series_one_neumann_hash.dig(:dispersion)
    @mode_one_neumann = series_one_neumann_hash.dig(:mode)
    @mean_one_neumann = series_one_neumann_hash.dig(:mean)

    series_two_neumann_hash = statistics_neumann(from, to, k, m, n_s, n_g)
    @series_two_neumann = series_two_neumann_hash.dig(:series)
    @dispersion_two_neumann = series_two_neumann_hash.dig(:dispersion)
    @mode_two_neumann = series_two_neumann_hash.dig(:mode)
    @mean_two_neumann = series_two_neumann_hash.dig(:mean)

    series_one_metropolis = statistics_metropolis(from, to, k, m, n_s, n_g)
    @series_one_metropolis = series_one_metropolis.dig(:series)
    @dispersion_one_metropolis = series_one_metropolis.dig(:dispersion)
    @mode_one_metropolis = series_one_metropolis.dig(:mode)
    @mean_one_metropolis = series_one_metropolis.dig(:mean)

    series_two_metropolis = statistics_metropolis(from, to, k, m, n_s, n_g)
    @series_two_metropolis = series_two_metropolis.dig(:series)
    @dispersion_two_metropolis = series_two_metropolis.dig(:dispersion)
    @mode_two_metropolis = series_two_metropolis.dig(:mode)
    @mean_two_metropolis = series_two_metropolis.dig(:mean)
  end

  # GET /parameters/new
  def new
    @parameter = Parameter.new
  end

  # GET /parameters/1/edit
  def edit
  end

  # POST /parameters or /parameters.json
  def create
    @parameter = Parameter.new(parameter_params)

    respond_to do |format|
      if @parameter.save
        format.html { redirect_to parameter_url(@parameter), notice: "Parameter was successfully created." }
        format.json { render :show, status: :created, location: @parameter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parameters/1 or /parameters/1.json
  def update
    respond_to do |format|
      if @parameter.update(parameter_params)
        format.html { redirect_to parameter_url(@parameter), notice: "Parameter was successfully updated." }
        format.json { render :show, status: :ok, location: @parameter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @parameter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parameters/1 or /parameters/1.json
  def destroy
    @parameter.destroy

    respond_to do |format|
      format.html { redirect_to parameters_url, notice: "Parameter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def save_to_xlsx
    id = params[:result_to_xlsx][:id]
    a = params[:result_to_xlsx][:a]
    b = params[:result_to_xlsx][:b]
    m = params[:result_to_xlsx][:m]
    k = params[:result_to_xlsx][:k]
    n_s = params[:result_to_xlsx][:n_s]
    n_g = params[:result_to_xlsx][:n_g]
    dispersion = params[:result_to_xlsx][:dispersion]
    mean_neumann = params[:result_to_xlsx][:mean_neumann]
    dispersion_neumann = params[:result_to_xlsx][:dispersion_neumann]
    mode_neumann = params[:result_to_xlsx][:mode_neumann]
    mean_metropolis = params[:result_to_xlsx][:mean_metropolis]
    dispersion_metropolis = params[:result_to_xlsx][:dispersion_metropolis]
    mode_metropolis = params[:result_to_xlsx][:mode_metropolis]

    p = Axlsx::Package.new
    ws = p.workbook.add_worksheet(:name => "Results of Modelling # #{id}")
    ws.styles.add_style(:bg_color => "FFE8E5E5", :sz => 14, :border => { :style => :thin, :color => "000000" })

    ws.add_row ["Результати моделювання # #{id}"]
    ws.add_row [""]
    ws.add_row ["Вхідні значення"]
    ws.add_row ["", "a", "b", "m", "k", "N_s", "N_g"]
    ws.add_row ["", a, b, m, k, n_s, n_g]
    ws.add_row ["Інтегральні характеристики"]
    ws.add_row ["", "Теоретичні значення", "Метод Неймана", "Метод Метрополіса"]
    ws.add_row ["Математичне очікування", m, mean_neumann, mean_metropolis]
    ws.add_row ["Дисперсія ", dispersion, dispersion_neumann, dispersion_metropolis]
    ws.add_row ["Мода ", m, mode_neumann, mode_metropolis]

    p.serialize("app/modeling_results_xlsx/Results_of_modeling_##{id}.xlsx")


  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_parameter
    @parameter = Parameter.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def parameter_params
    params.require(:parameter).permit(:from, :to, :m, :k, :n_s, :n_g)
  end

  def von_mises_cdf(bottom_limit, upper_limit, m, k, n_s)
    VonMisesDistribution.von_mises_cdf(bottom_limit, upper_limit, m, k, n_s)
  end

  def von_mises_approximation(bottom_limit, upper_limit, k, m, n_g)
    p_k = Array.new

    VonMisesDistribution.von_mises_approximation(bottom_limit, upper_limit, k, m, n_g).each do |key, value|
      interval = "#{value[0][0].round(3)} - #{value[0][1].round(3)}"
      value = value[1].round(3)
      p_k << [interval, value]
    end

    p_k
  end

  def statistics_neumann(from, to, k, m, n_s, n_g)
    result = Hash.new

    neumann_array = NeumannModule.von_mises_neumann(from, to, k, m, n_s)
    p_k_frequency = SeriesModule.p_k_frequency(from, to, neumann_array, n_g)
    ro_k = SeriesModule.statistical_estimates(p_k_frequency)
    result[:series] = view_histogram_array(ro_k)
    result[:dispersion] = StatisticalCheckModule.dispersion(neumann_array)
    result[:mean] = StatisticalCheckModule.mean(neumann_array)
    result[:mode] = StatisticalCheckModule.mode(neumann_array)

    result
  end

  def statistics_metropolis(from, to, k, m, n_s, n_g)
    result = Hash.new

    metropolis_array = MetropolisModule.von_mises_metropolis(from, to, k, m, n_s)
    p_k_frequency = SeriesModule.p_k_frequency(from, to, metropolis_array, n_g)
    ro_k = SeriesModule.statistical_estimates(p_k_frequency)
    result[:series] = view_histogram_array(ro_k)
    result[:dispersion] = StatisticalCheckModule.dispersion(metropolis_array)
    result[:mean] = StatisticalCheckModule.mean(metropolis_array)
    result[:mode] = StatisticalCheckModule.mode(metropolis_array)

    result
  end

  def view_histogram_array(hash)
    array = Array.new

    hash.each do |key, value|
      interval = "#{value[0][0].round(3)} - #{value[0][1].round(3)}"
      value = value[1].round(3)
      array << [interval, value]
    end

    array
  end

end
