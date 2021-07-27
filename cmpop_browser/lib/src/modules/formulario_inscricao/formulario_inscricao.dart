import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/shared/components/angular_recaptcha/angular_recaptcha.dart';

import 'package:cmpop_browser/src/shared/components/file_upload_component/file_upload_component.dart';

import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:cmpop_browser/src/shared/components/simple_loading/simple_loading.dart';
import 'package:cmpop_browser/src/shared/directives/custom_validator_directive.dart';
import 'package:cmpop_browser/src/shared/directives/date_value_accessor.dart';
import 'package:cmpop_browser/src/shared/directives/textmask_directive.dart';
import 'package:cmpop_browser/src/shared/repositories/bairros_repository.dart';

import 'dart:html' as html;

import 'package:cmpop_core/cmpop_core.dart';
import 'package:uuid/uuid.dart';

enum FormularioState { tipoPessoa, inicio, validacao, fim }

@Component(
    selector: 'formulario-inscricao-page',
    styleUrls: ['formulario_inscricao.css'],
    templateUrl: 'formulario_inscricao.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
      AngularRecaptcha,
      CustomValidatorDirective,
      TextMaskDirective,
      DateValueAccessor,
      FileUploadComponent,
    ],
    providers: [FORM_PROVIDERS, ClassProvider(BairrosRepository)],
    exports: [FormularioState],
    pipes: [commonPipes])
class FormularioIncricaoPage implements OnInit, AfterContentInit, AfterViewInit, OnActivate, OnDestroy {
  final FormularioInscricaoApi formularioInscricaoApi;
  final BairrosRepository bairrosRepository;

  StreamSubscription streamSubscriptionChangeIdioma;
  SimpleLoadingComponent loading;
  List<Categoria> categorias;

  Categoria categoriaAlimentacao;

  FormularioInscricaoModel formulario = FormularioInscricaoModel(
    id: Uuid().v4(),
    dataCadastro: DateTime.now(),
  );

  bool euConfirmoOsDados = false;
  FormularioState formularioState = FormularioState.inicio;

  bool showSelectDiaSemana = false;

  @ViewChild('container')
  html.DivElement container;

  @ViewChild('cpfOrCnpj')
  html.InputElement cpfOrCnpj;

  TextMaskDirective maskCpfOrCnpj;
  List<String> bairros = <String>[];

  //contrutor
  FormularioIncricaoPage(this.formularioInscricaoApi, this.bairrosRepository) {
    loading = SimpleLoadingComponent();
    bairros = bairrosRepository.bairros();
  }

  //https://www.google.com/recaptcha/admin/site/448179072/setup
  //desenv.pmro@gmail.com
  var recaptchaKey = '6LeAq7YaAAAAADe-PND8FF6gdh0DhME98CMFDG2N';
  String recaptchaValue;

  ///ORGANIZADOR DA EXCURSÃO: Pessoa Física | Pessoa Jurídica
  RadioButtonState _pessoaFisica = RadioButtonState(true, 'fisica');
  RadioButtonState _pessoaJuridica = RadioButtonState(false, 'juridica');
  RadioButtonState get pessoaFisica => _pessoaFisica;
  set pessoaFisica(RadioButtonState pf) {
    _pessoaFisica = pf;
    formulario.tipoPessoa = _pessoaFisica.value;
    changeOrganizadorTipoPessoaHandle(_pessoaFisica.value);
  }

  RadioButtonState get pessoaJuridica => _pessoaJuridica;
  set pessoaJuridica(RadioButtonState pj) {
    _pessoaJuridica = pj;
    formulario.tipoPessoa = _pessoaJuridica.value;
    changeOrganizadorTipoPessoaHandle(_pessoaJuridica.value);
  }

  void changeOrganizadorTipoPessoaHandle(String value) {
    if (value == 'fisica') {
      //maskCadasturOrCPFOrganizador.textMask = 'xxx.xxx.xxx-xx';
      // cadasturOrCPFOrganizador.attributes['data-validation-type'] = 'cpf';
    } else if (value == 'juridica') {
      //maskCadasturOrCPFOrganizador.textMask = 'xx.xxx.xxx/xxxx-xx';
      // cadasturOrCPFOrganizador.attributes['data-validation-type'] = 'cnpj';
    }
  }

  @override
  void ngOnInit() async {}

  @override
  void ngAfterContentInit() {}

  @override
  void ngAfterViewInit() {
    /* maskCpfOrCnpj = TextMaskDirective(cpfOrCnpj);
    maskCpfOrCnpj.textMask = 'xx.xxx.xxx/xxxx-xx';*/
  }

  @override
  void onActivate(RouterState previous, RouterState current) async {
    html.window.scrollTo(0, 0);
  }

  @override
  void ngOnDestroy() {
    streamSubscriptionChangeIdioma?.cancel();
  }

  Future<bool> isExist() async {
    try {
      loading.show();
      var resp = await formularioInscricaoApi.findByMap({'cnpj': formulario.cnpj});
      loading.hide();
      if (resp.result?.isNotEmpty == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      loading.hide();
      return false;
    }
  }

  void validarCnpj() {
    //print('validarCnpj');
    formularioState = FormularioState.inicio;
  }

  bool arquivosValidados = false;

  void fileChangeHandle(FormularioAnexo a) {
    arquivosValidados = a != null;
  }

  void validarForm() async {
    if (!arquivosValidados) {
      SimpleDialogComponent.showAlert('Você não anexou os documentos.');
      return;
    }
    /* var isexist = await isExist();
    if (isexist) {
      SimpleDialogComponent.showAlert('Este CNPJ já está cadastrado em nosso banco de dados.');
      return;
    }*/
    print('validarForm');

    formularioState = FormularioState.validacao;
  }

  void enviaForm() async {
    if (recaptchaValue == null) {
      SimpleDialogComponent.showAlert('Click em Não sou um robo ou preencha a Captcha');
      return;
    }
    if (!euConfirmoOsDados) {
      SimpleDialogComponent.showAlert('Click em Eu sou responsável por todas as informações fornecidas aqui.');
      return;
    }
    try {
      loading.show();
      await formularioInscricaoApi.enviaFormularioToEmail(formulario);
      formularioState = FormularioState.fim;
    } catch (e, s) {
      print('FormularioInventarioPage@enviaForm $e $s');
      SimpleDialogComponent.showAlert('Erro ao envia, tente mais tarde');
    } finally {
      loading.hide();
      // formularioState = FormularioState.fim;
    }
  }
}
