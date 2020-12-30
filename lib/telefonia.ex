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
  def buscar_assinante(numero, plano \\ :all), do: Assinante.buscar_assinante(numero, plano)

  @doc """
  Funcao que busca todos os assinante, sejam eles `prepago` ou `pospago` usando a funcao `Assinante.assinantes/0`
  """
  def listar_assinantes, do: Assinante.assinantes()

  @doc """
    Funcao que faz busca por assinantes `prepago` usando a funcao `Assinante.assinantes_prepago/0`

  """
  def listar_assinantes_prepago, do: Assinante.assinantes_prepago()

  @doc """
  Funcao que faz busca por assinantes `pospago` usando a funcao `Assinante.assinantes_pospago/0`
  """
  def listar_assinantes_pospago, do: Assinante.assinantes_pospago()

  @doc """
  Funcao para um assinante fazer uma chamada que chama a funcao `Prepago.fazer_chamada/3` se o assinante for `prepago`, e se o assinante for `pospago` chamada a funcao `Pospago.fazer_chamada/3`
  """
  def fazer_chamada(numero, plano, data, duracao) do
    cond do
      Assinante.buscar_assinante(numero) != nil ->
        cond do
          plano == :prepago ->
            Prepago.fazer_chamada(numero, data, duracao)

          plano == :pospago ->
            Pospago.fazer_chamada(numero, data, duracao)
        end

      Assinante.buscar_assinante(numero) == nil ->
        {:error, "Assinante nao existe"}
    end
  end

  @doc """
  Funcao para que um assinante `prepago` possa fazer uma nova recarga usando a funcao `Recarga.nova/3`
  """
  def recarga(numero, data, valor), do: Recarga.nova(data, valor, numero)

  @doc """
  Funcao para fazer a impressa de registros feitos pelo assinante em determinado `mes` e `ano`, utilizando a funcao `Prepago.imprimir_conta/3` para impressao de informacoes dos assinantes com plano `prepago` e a funcao `Pospago.imprimir_conta/3` para impressao de informacoes referente a assinantes `prepago`

  ## Parametros da funcao

  - mes: mes que pretende fazer a busca
  - ano: ano que pretende fazer a busca
  """
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
