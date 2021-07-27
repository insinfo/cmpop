import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/modules/admin/components/pagination2/pagination2.dart';
import 'package:cmpop_browser/src/shared/components/file_upload_component/file_upload_component.dart';
import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:cmpop_browser/src/shared/components/simple_loading/simple_loading.dart';
import 'package:cmpop_browser/src/shared/directives/date_value_accessor.dart';
import 'package:cmpop_browser/src/shared/directives/textmask_directive.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_browser/src/shared/repositories/bairros_repository.dart';

import 'package:cmpop_core/cmpop_core.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

@Component(
    selector: 'gerencia-inscricao',
    styleUrls: ['gerencia_inscricao.css'],
    templateUrl: 'gerencia_inscricao.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
      AutoDismissDirective,
      AutoFocusDirective,
      MaterialIconComponent,
      MaterialButtonComponent,
      MaterialTooltipDirective,
      MaterialDialogComponent,
      ModalComponent,
      Pagination2Component,
      TextMaskDirective,
      DateValueAccessor,
      FileUploadComponent,
    ],
    providers: [overlayBindings, FORM_PROVIDERS, ClassProvider(BairrosRepository)],
    pipes: [TruncatePipe, commonPipes],
    exports: [iconsPictogramascmpop])
class GerenciaInscricaoComponent implements OnInit, OnActivate {
  final FormularioInscricaoApi api;
  final BairrosRepository bairrosRepository;
  final CategoriaApi categoriaApi;

  FormularioInscricaoModel formulario;

  List<FormularioInscricaoModel> items = <FormularioInscricaoModel>[];

  List<Categoria> categorias = <Categoria>[];
  List<String> bairros = <String>[];
  bool showModal = false;

  bool isEditing = false;
  SimpleLoadingComponent loading;
  bool isInFullscreenMode = false;

  @ViewChild('container')
  html.DivElement container;

  @ViewChild('modalContainer')
  html.DivElement modalContainer;

//----------- inicio paginação -----------
  @ViewChild('pagination')
  Pagination2Component pagination;
  @ViewChild('select')
  html.SelectElement selectItemsPerPage;
  @ViewChild('inputSearch')
  html.InputElement inputSearch;
  int totalRecords = 0;
  Filtros filtros = Filtros(limit: 40, offset: 0, searchFields: ['nomeFantasia', 'razaoSocial', 'cnpj']);
  void changePage(Filtros f) async {
    // filtros = f;
    refresh();
  }

  void searchEnterHandle(value) {
    filtros.search = value;
    refresh();
  }

  void itemsPerPageChange(html.SelectElement sel) {
    filtros.limit = int.tryParse(sel.value);
    refresh();
  }
//----------- fim paginação -----------

  GerenciaInscricaoComponent(this.api, this.categoriaApi, this.bairrosRepository) {
    loading = SimpleLoadingComponent();
    bairros = bairrosRepository.bairros();
  }

  void initInstances() {
    formulario = FormularioInscricaoModel(dataCadastro: DateTime.now());
  }

  void reset() {
    filtros.limit = 40;
    filtros.offset = 0;
    filtros.search = '';
    selectItemsPerPage.options.firstWhere((e) => e.value == '${filtros.limit}').selected = true;
    inputSearch.value = '';
    refresh();
  }

  void refresh() {
    getAll();
    pagination?.update();
  }

  ///ORGANIZADOR DA EXCURSÃO: Pessoa Física | Pessoa Jurídica
  RadioButtonState _pessoaFisica = RadioButtonState(true, 'fisica');
  RadioButtonState _pessoaJuridica = RadioButtonState(false, 'juridica');
  RadioButtonState get pessoaFisica => _pessoaFisica;
  set pessoaFisica(RadioButtonState pf) {
    _pessoaFisica = pf;
    formulario.tipoPessoa = _pessoaFisica.value;
  }

  RadioButtonState get pessoaJuridica => _pessoaJuridica;
  set pessoaJuridica(RadioButtonState pj) {
    _pessoaJuridica = pj;
    formulario.tipoPessoa = _pessoaJuridica.value;
  }

  bool arquivosValidados = false;

  void fileChangeHandle(FormularioAnexo a) {
    arquivosValidados = a != null;
  }

  Future<void> getAll() async {
    loading.show(target: container);
    try {
      var resp = await api.all(filtros);
      items = resp.asTypedResults<FormularioInscricaoModel>((x) => FormularioInscricaoModel.fromMap(x));
      totalRecords = resp.totalRecords;
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e');
      print('CadastroInventarioComponent@getAll $e $s');
    }
    loading.hide();
  }

  void adicionar() {
    showModal = true;
    isEditing = false;
    initInstances();
  }

  void editar(FormularioInscricaoModel u) {
    initInstances();
    formulario = u;
    showModal = true;
    isEditing = true;
  }

  void remover(FormularioInscricaoModel cat) {
    SimpleDialogComponent.showConfirm('Tem certesa?', confirmAction: () async {
      try {
        loading.show(target: container);
        await api.deleteById(cat.id);
        items.remove(cat);
        loading.hide();
      } catch (e, s) {
        SimpleDialogComponent.showAlert('Erro ao remover', subMessage: '$e');
        print('remover $e $s');
      } finally {
        loading.hide();
      }
    });
  }

  void salvar() async {
    try {
      loading.show(target: modalContainer);
      if (isEditing) {
        await api.updateById(formulario.toMap(), formulario.id);
      } else {
        formulario.dataCadastro = DateTime.now();
        formulario.id = Uuid().v4();
        await api.create(formulario.toMap());
        items.add(formulario);
      }
      showModal = false;
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao salvar', subMessage: '$e $s');
      print('salvar $e $s');
    } finally {
      loading.hide();
    }
  }

  void cancelar() {
    showModal = false;
    isEditing = false;
  }

  @override
  void ngOnInit() async {}

  @override
  void onActivate(RouterState previous, RouterState current) async {
    initInstances();
    await getAll();
  }
}
