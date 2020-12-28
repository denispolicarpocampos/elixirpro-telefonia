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
end
