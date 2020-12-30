defmodule Assinante do
  @moduledoc """
  Modulo de assinante para cadastro de tipos de assinantes como `prepago` e `pospago`

  A funcao mais utilizada e a funcao `cadastrar/4`
  """

  defstruct nome: nil, numero: nil, cpf: nil, plano: nil, chamadas: []
  @assinantes %{:prepago => "pre.txt", :pospago => "pos.txt"}

  @doc """
  Funcao para fazer a busca por assinantes, passando o seu `numero` unico e podendo passar seu plano, sendo `pospago` ou `prepago`, se nao passado nenhum plano ele buscara pelos dois planos, fazendo uso da funcao `Assinante.filtro/2` passando a lista de assinantes e o numero

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

  @doc """
  Funcao que faz um filtro na lista de assinantes, buscando por correspondencia de numero

  ## Parametros da funcao

  - lista: lista de assinantes que sera aplicado o filtro
  - numero: numero que sera filtrado na lista
  """
  def filtro(lista, numero), do: Enum.find(lista, &(&1.numero === numero))

  @doc """
  Funcao que busca todos os assinante, sejam eles `prepago` ou `pospago`
  """
  def assinantes(), do: read(:prepago) ++ read(:pospago)

  @doc """
  Funcao que faz busca por assinantes `pospago`
  """
  def assinantes_pospago(), do: read(:pospago)

  @doc """
  Funcao que faz busca por assinantes `prepago`
  """
  def assinantes_prepago(), do: read(:prepago)

  @doc """
  Funcao para cadastrar assinante seja ele `prepago` e `pospago`

  ## Parametros da funcao

  - nome: parametro do nome do assinante
  - numero: numero unico e caso exista pode retornar um erro
  - cpf: parametro de assinante
  - plano: podendo passar `prepago` ou `pospago`

  ## Informacoes Adicionais

  - caso o numero ja exista ele exibira uma mensagem de erro

  ## Exemplo

      iex> Assinante.cadastrar("Teste", "123123", "123123", :prepago)
      {:ok, "Assinante Teste cadastrado com sucesso"}
  """
  def cadastrar(nome, numero, cpf, :prepago), do: cadastrar(nome, numero, cpf, %Prepago{})
  def cadastrar(nome, numero, cpf, :pospago), do: cadastrar(nome, numero, cpf, %Pospago{})

  def cadastrar(nome, numero, cpf, plano) do
    case buscar_assinante(numero) do
      nil ->
        assinante = %__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano}

        (read(pega_plano(assinante)) ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante))

        {:ok, "Assinante #{nome} cadastrado com sucesso"}

      _assinante ->
        {:error, "Assinante com este numero Cadastrado!"}
    end
  end

  @doc """
  Funcao para fazer atualizao de dados do assinante

  ## Paramentros da funcao

  - numero: numero do assinante
  - assinante: passando o assinante que sera atualizado

  ## Informacoes adicionais

  - Caso o assinante nao exista, retornara uma tupla com error e mensagem

  ## Exemplo

      iex> Assinante.atualizar("123", %Assinante{nome: "Teste", numero: "123", cpf: "123", plano: :pospago})
      {:error, "Assinante nao pode ser atualizado, pois o mesmo nao existe na base de dados"}
  """
  def atualizar(numero, assinante) do
    cond do
      Assinante.buscar_assinante(numero) != nil ->
        {assinante_antigo, nova_lista} = deletar_item(numero)

        case assinante.plano.__struct__ == assinante_antigo.plano.__struct__ do
          true ->
            (nova_lista ++ [assinante])
            |> :erlang.term_to_binary()
            |> write(pega_plano(assinante))

          false ->
            {:error, "Assinante nao pode alterar o plano"}
        end

      Assinante.buscar_assinante(numero) == nil ->
        {:error, "Assinante nao pode ser atualizado, pois o mesmo nao existe na base de dados"}
    end
  end

  @doc """
  Funcao que acessa a struct do plano de um assinante e retorna `prepago` ou `pospago`

  ## Parametros da funcao

  - assinante: assinante que sera passado
  """
  def pega_plano(assinante) do
    case assinante.plano.__struct__ == Prepago do
      true -> :prepago
      false -> :pospago
    end
  end

  @doc """
  Funcao para deletar um assinante passando o `numero` cadastrado, e fazendo a escrita no banco de dados

  ## Parametros da funcao

  - numero: numero do assinante

  ## Informacoes adicionais

  - Caso o assinante nao exista, retornara uma tupla com error e mensagem

  ## Exemplo

      iex> Assinante.deletar("123")
      {:error, "Assinante nao pode ser deletado, pois o mesmo nao existe na base de dados"}
  """
  def deletar(numero) do
    cond do
      Assinante.buscar_assinante(numero) != nil ->
        {assinante, nova_lista} = deletar_item(numero)

        nova_lista
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante))

        {:ok, "Assinante #{assinante.nome} deletado!"}

      Assinante.buscar_assinante(numero) == nil ->
        {:error, "Assinante nao pode ser deletado, pois o mesmo nao existe na base de dados"}
    end
  end

  @doc """
  Funcao para deletar um assinante passando o `numero` cadastrado, retornando uma tupla com  assinante uma nova lista onde nao contem esse assinante

  ## Parametros da funcao

  - numero: numero do assinante

  ## Informacoes adicionais

  - Caso o assinante nao exista, retornara uma tupla com error e mensagem

  ## Exemplo

      iex> Assinante.deletar("123")
      {:error, "Assinante nao pode ser deletado, pois o mesmo nao existe na base de dados"}
  """
  def deletar_item(numero) do
    assinante = buscar_assinante(numero)

    nova_lista =
      read(pega_plano(assinante))
      |> List.delete(assinante)

    {assinante, nova_lista}
  end

  @doc """
  Funcao que salva as informacoes nos arquivos, pegando uma lista de assinantes e o plano, se `prepago` ou `pospago`, para salvar em determinado arquivo

  ## Parametro da funcao

  - lista_assinantes: a lista de assinantes que vai ser salva no arquivo
  - plano: plano do assinante corresponde ao arquivo que sera salvo
  """
  def write(lista_assinantes, plano) do
    File.write(@assinantes[plano], lista_assinantes)
  end

  @doc """
  Funcao que le as informacoes de um determinado arquivo que sera passado via parametro.

  ## Parametros da funcao

  - plano: corresponde ao arquivo que sera lido, sendo `pospago` ou `prepago`
  """
  def read(plano) do
    case File.read(@assinantes[plano]) do
      {:ok, assinantes} ->
        assinantes
        |> :erlang.binary_to_term()

      {:error, :ennoent} ->
        {:erro, "Arquivo nao encontrado!"}
    end
  end
end
