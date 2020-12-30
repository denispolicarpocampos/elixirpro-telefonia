defmodule Contas do
  @moduledoc """
  Modulo de Contas para fazer a impressao de registros que o assinante fez
  """

  @doc """
  Funcao para fazer a impressa de registros feitos pelo assinante em determinado `mes` e `ano`, utilizando a funcao `Assinante.buscar_assinante/2` para ver se o assinante existe

  ## Parametros da funcao

  - mes: mes que pretende fazer a busca
  - ano: ano que pretende fazer a busca
  - numero: numero do assinante que pretende fazer a impressao
  - plano: plano do assinante

  ## Informacoes adicionais

  - Se o assinante nao existir a funcao retorara uma tupla com erro e mensagem

  ## Exemplo

      iex> Contas.imprimir(12, 2020, "123", :pospago)
      {:error, "Assinante nao existe"}

  """
  def imprimir(mes, ano, numero, plano) do
    cond do
      Assinante.buscar_assinante(numero) != nil ->
        assinante = Assinante.buscar_assinante(numero)
        chamadas_do_mes = busca_elementos_mes(assinante.chamadas, mes, ano)

        cond do
          plano == :prepago ->
            recargas_do_mes = busca_elementos_mes(assinante.plano.recargas, mes, ano)
            plano = %Prepago{assinante.plano | recargas: recargas_do_mes}
            %Assinante{assinante | chamadas: chamadas_do_mes, plano: plano}

          plano == :pospago ->
            %Assinante{assinante | chamadas: chamadas_do_mes}
        end

      Assinante.buscar_assinante(numero) == nil ->
        {:error, "Assinante nao existe"}
    end
  end

  @doc """
  Funcao para fazer busca de elementos por mes e ano

  ## Parametros da funcao

  - elementos: lista de assinantes que sera filtrada
  - mes: mes que sera aplicado o filtro
  - ano: ano que sera aplicado o filtro
  """
  def busca_elementos_mes(elementos, mes, ano) do
    elementos
    |> Enum.filter(&(&1.data.year == ano and &1.data.month == mes))
  end
end
