class Api::MoneyController < ApplicationController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  def insert
    coints = Money.find_by(sum_of_coint: permitted_params_for_insert[:coint][:sum_of_coint])
    if coints
        .update_attributes!(quantity: coints.quantity + permitted_params_for_insert[:coint][:quantity].to_f)
      render :status => 200,
             :json => { success: true, coint: coints.sum_of_coint, quantity: coints.quantity }
    else
      render :status => 200,
             :json => { success: false , message: coints.errors.full_messages }
    end
  end

  def exchange
    denomination = permitted_params_exchange[:denomination][:sum].to_i
    if denomination <= balance
      exchange_nominals = calculate_exchange_nominals(denomination)
      take_coint_nominals_from_storage(exchange_nominals)
      render :status => 200,
             :json => { success: true, result: exchange_nominals}
    else
      render :status => 200,
             :json => { success: false, result: 'Not enough money in machine'}
    end
  end

  private

  def calculate_exchange_nominals(sum)
    possible_solution = {}

    sorted_nominals = Money::COINTS.reverse

    current_sum = sum

    sorted_nominals.each do |current_nominal|
      possible_solution[current_nominal] = get_possible_count_of_nominal(current_sum, current_nominal)
      current_sum -= current_nominal * possible_solution[current_nominal]
    end

    sum_of_possible_solution = 0

    possible_solution.each do |k, v|
      sum_of_possible_solution += k*v
    end

    if sum_of_possible_solution != sum
      return "Can't exchage this denomination"
    else
      possible_solution
    end
  end

  def get_possible_count_of_nominal(sum, nominal)
    maximal_count = sum / nominal
    if Money.find_by(sum_of_coint: nominal).quantity < maximal_count
      Money.find_by(sum_of_coint: nominal).quantity
    else
      maximal_count
    end
  end

  def balance
    balance = 0
    Money.all.each do |c|
      balance += c.quantity * c.sum_of_coint
    end
    return balance
  end

  def take_coint_nominals_from_storage(exchange_nominals)
    exchange_nominals.each do |k,v|
      coints = Money.find_by(sum_of_coint: k)
      coints.update_attributes!(quantity: coints.quantity - v)
    end
  end

  def permitted_params_for_insert
    { coint:
        params.fetch(:coint, {}).permit(:quantity, :sum_of_coint)}
  end

  def permitted_params_exchange
    { denomination:
        params.fetch(:denomination, {}).permit(:sum)}
  end
    #curl -v -H 'Content-Type: application/json' -H 'Accept: application/json' -X PATCH http://localhost:3000/api/insert -d "{\"coint\":{\"sum_of_coint\":\"5\", \"quantity\":\"11\"}}"
    #curl -v -H 'Content-Type: application/json' -H 'Accept: application/json' -X PATCH http://localhost:3000/api/exchange -d "{\"denomination\":{\"sum\":\"200\"}}"
end