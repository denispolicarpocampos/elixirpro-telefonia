defmodule Assinante do
  @moduledoc """
  Modulo de assinante para cadastro de tipos de assinantes como `prepago` e `pospago`

  A funcao mais utilizada e a funcao `cadastrar/4`
  """

  defstruct nome: nil, numero: nil, cpf: nil, plano: nil
  @assinantes %{:prepago => "pre.txt", :pospago => "pos.txt"}

  @doc """
  Funcao para fazer a busca por assinantes, passando o seu `numero` unico e podendo passar seu plano, sendo `pospago` ou `prepago`, se nao passado nenhum plano ele buscara pelos dois planos

  ## Parametros da funcao

  - numero: numero unico caso nao exista retorna erro
  - key: podendo ser `pospago` ou `prepago`

  ## Informacoes adicionais

  - Caso o assinante nao exista retornara como `nil`

  ## Exemplo

      iex> Assinante.buscar_assinante("1234", :pospago)
      nil
  """

  def buscar_assinante(numero, key \\ :all), do: buscar(numero, key)

  defp buscar(numero, :all), do: filtro(assinantes(), numero)
  defp buscar(numero, :pospago), do: filtro(assinantes_pospago(), numero)
  defp buscar(numero, :prepago), do: filtro(assinantes_prepago(), numero)

  defp filtro(lista, numero), do: Enum.find(lista, &(&1.numero === numero))

  defp assinantes(), do: read(:prepago) ++ read(:pospago)
  defp assinantes_pospago(), do: read(:pospago)
  defp assinantes_prepago(), do: read(:prepago)

  @doc """
  Funcao para cadastrar assinante seja ele `prepago` e `pospago`

  ## Parametros da funcao

  - nome: parametro do nome do assinante
  - numero: numero unico e caso exista pode retornar um erro
  - cpf: parametro de assinante
  - plano: opcional e casa nao seja infromado sera cadastrado um assinante `prepago`

  ## Informacoes Adicionais

  - caso o numero ja exista ele exibira uma mensagem de erro

  ## Exemplo

      iex> Assinante.cadastrar("Marlon", "123123", "123123")
      {:ok, "Assinante Marlon cadastrado com sucesso"}
  """
  def cadastrar(nome, numero, cpf, plano) do
    case buscar_assinante(numero) do
      nil ->
        (read(plano) ++ [%__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano}])
        |> :erlang.term_to_binary()
        |> write(plano)

        {:ok, "Assinante #{nome} cadastrado com sucesso"}

      _assinante ->
        {:error, "Assinante com este numero Cadastrado!"}
    end
  end

  def deletar(numero) do
    assinante = buscar_assinante(numero)

    result_delete =
      assinantes()
      |> List.delete(assinante)
      |> :erlang.term_to_binary()
      |> write(assinante.plano)

    {result_delete, "Assinante #{assinante.nome} deletado!"}
  end

  defp write(lista_assinantes, plano) do
    File.write(@assinantes[plano], lista_assinantes)
  end

  defp read(plano) do
    case File.read(@assinantes[plano]) do
      {:ok, assinantes} ->
        assinantes
        |> :erlang.binary_to_term()

      {:error, :ennoent} ->
        {:erro, "Arquivo nao encontrado!"}
    end
  end
end
