defmodule Telefonia do
  @moduledoc """
  Modulo geral da telefonia, sendo ela que fara a chamada aos metodos contidos dentro de cada assinante.

  A funcao `cadastrar_assinante/4` sendo a mais utilizada
  """

  @doc """
  Funcao que fara a criacao dos arquivos iniciais de dados `pos.txt` e `pre.txt`, para que possam ser cadastrado novos assinantes
  """
  def start do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))
  end

  @doc """
  Funcao que faz ponte para o `Assinante.cadastrar/4` para que assim seja cadastrado um novo cliente
  """
  def cadastrar_assinante(nome, numero, cpf, plano) do
    Assinante.cadastrar(nome, numero, cpf, plano)
  end

  @doc """
  Funcao que faz ponte para o `Assinante.buscar_assinante/2` para que assim ocorra a busca por um assinante
  """
  def buscar_assinante(numero, key \\ :all) do
    Assinante.buscar_assinante(numero, key)
  end

  def listar_assinantes, do: Assinante.assinantes()
  def listar_assinantes_prepago, do: Assinante.assinantes_prepago()
  def listar_assinantes_pospago, do: Assinante.assinantes_pospago()

  def fazer_chamada(numero, plano, data, duracao) do
    cond do
      plano == :prepago ->
        Prepago.fazer_chamada(numero, data, duracao)

      plano == :pospago ->
        Pospago.fazer_chamada(numero, data, duracao)
    end
  end

  def recarga(numero, data, valor), do: Recarga.nova(data, valor, numero)

  def buscar_por_numero(numero, plano \\ :all), do: Assinante.buscar_assinante(numero, plano)

  def imprimir_contas(mes, ano) do
    Assinante.assinantes_prepago()
    |> Enum.each(fn assinante ->
      assinante = Prepago.imprimir_conta(mes, ano, assinante.numero)
      IO.puts("=======================================================")
      IO.puts("Conta Prepaga do Assinante #{assinante.nome}")
      IO.puts("Numero: #{assinante.numero}")
      IO.puts("Chamadas: ")
      IO.inspect(assinante.chamadas)
      IO.puts("Recargas: ")
      IO.inspect(assinante.plano.recargas)
      IO.puts("Total de Chamadas: #{Enum.count(assinante.chamadas)}")
      IO.puts("Total de Recargas: #{Enum.count(assinante.plano.recargas)}")
      IO.puts("=======================================================")
    end)

    Assinante.assinantes_pospago()
    |> Enum.each(fn assinante ->
      assinante = Pospago.imprimir_conta(mes, ano, assinante.numero)
      IO.puts("=======================================================")
      IO.puts("Conta Pospaga do Assinante #{assinante.nome}")
      IO.puts("Numero: #{assinante.numero}")
      IO.puts("Chamadas: ")
      IO.inspect(assinante.chamadas)
      IO.puts("Total de Chamadas: #{Enum.count(assinante.chamadas)}")
      IO.puts("Valor da Fatura: #{assinante.plano.valor}")
      IO.puts("=======================================================")
    end)
  end
end
