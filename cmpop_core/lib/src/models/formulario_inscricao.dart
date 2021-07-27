import 'anexo.dart';

///formulário inscrição
class FormularioInscricaoModel {
  FormularioInscricaoModel({
    this.dataCadastro,
    this.id,
  });

  String id;
  DateTime dataCadastro;

  String nome;
  String cpf;
  String rg;
  DateTime dataNascimento;

  /// Razão Social
  String razaoSocial;

  /// Nome Fantasia:
  String nomeFantasia;

  /// Nº CNPJ:
  String cnpj;

  String logradouro;
  String numero;
  String bairro;
  String cep;
  String complemento;

  /// Telefones de Contato:
  String telefoneFixo;
  String telefoneCelular;
  String email;

  /// Fisica | Juridica
  String tipoPessoa;

  /// HtmlElement Files fotos da fachada e do estabelecimento
  List<FormularioAnexo> files = <FormularioAnexo>[];

  FormularioInscricaoModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];

    nome = map['nome'];
    cpf = map['cpf'];
    rg = map['rg'];
    tipoPessoa = map['tipoPessoa'];

    razaoSocial = map['razaoSocial'];
    nomeFantasia = map['nomeFantasia'];
    cnpj = map['cnpj'];
    logradouro = map['logradouro'];
    numero = map['numero'];
    bairro = map['bairro'];
    cep = map['cep'];
    complemento = map['complemento'];
    email = map['email'];
    telefoneFixo = map['telefoneFixo'];
    telefoneCelular = map['telefoneCelular'];

    if (map.containsKey('dataNascimento')) {
      if (map['dataNascimento'] != null) {
        dataNascimento = DateTime.tryParse(map['dataNascimento'].toString());
      }
    }

    if (map.containsKey('dataCadastro')) {
      if (map['dataCadastro'] != null) {
        dataCadastro = DateTime.tryParse(map['dataCadastro'].toString());
      }
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }

    map['nome'] = nome;
    map['cpf'] = cpf;
    map['rg'] = rg;
    map['tipoPessoa'] = tipoPessoa;
    map['razaoSocial'] = razaoSocial;
    map['nomeFantasia'] = nomeFantasia;
    map['cnpj'] = cnpj;
    map['logradouro'] = logradouro;
    map['numero'] = numero;
    map['bairro'] = bairro;
    map['cep'] = cep;
    map['complemento'] = complemento;
    map['email'] = email;
    map['telefoneFixo'] = telefoneFixo;
    map['telefoneCelular'] = telefoneCelular;
    map['dataCadastro'] = dataCadastro?.toString();
    map['dataNascimento'] = dataNascimento?.toString();

    return map;
  }
}
