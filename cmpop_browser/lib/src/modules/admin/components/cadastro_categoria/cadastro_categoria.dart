import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:cmpop_browser/src/shared/components/simple_loading/simple_loading.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

@Component(
    selector: 'cadastro-categoria',
    styleUrls: ['cadastro_categoria.css'],
    templateUrl: 'cadastro_categoria.html',
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
    ],
    providers: [overlayBindings],
    pipes: [TruncatePipe, commonPipes],
    exports: [iconsPictogramascmpop])
class CadastroCategoriaComponent implements OnInit, OnActivate {
  final CategoriaApi categoriaApi;

  Categoria categoria;
  List<Categoria> categorias = <Categoria>[];
  bool showModal = false;

  bool isEditing = false;
  SimpleLoadingComponent loading;
  bool isInFullscreenMode = false;

  @ViewChild('container')
  html.DivElement container;

  @ViewChild('modalContainer')
  html.DivElement modalContainer;

  CadastroCategoriaComponent(this.categoriaApi) {
    loading = SimpleLoadingComponent();
  }

  void initInstances() {
    categoria = Categoria(dataCadastro: DateTime.now());
  }

  void refresh() {
    getAll();
  }

  Future<void> getAll() async {
    loading.show(target: container);
    try {
      categorias.clear();
      var resp = await categoriaApi.all(Filtros());
      categorias = resp.asTypedResults<Categoria>((x) => Categoria.fromMap(x));
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e');
      print('getAll $e $s');
    }
    loading.hide();
  }

  void adicionar() {
    showModal = true;
    isEditing = false;
    initInstances();
  }

  void editar(Categoria u) {
    initInstances();
    categoria = u;
    showModal = true;
    isEditing = true;
  }

  void remover(Categoria cat) {
    SimpleDialogComponent.showConfirm('Tem certesa?', confirmAction: () async {
      try {
        loading.show(target: container);
        await categoriaApi.deleteById(cat.id);
        categorias.remove(cat);
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
        await categoriaApi.updateById(categoria.toMap(), categoria.id);
      } else {
        categoria.dataCadastro = DateTime.now();
        categoria.id = Uuid().v4();
        await categoriaApi.create(categoria.toMap());
        categorias.add(categoria);
      }
      showModal = false;
      loading.hide();
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
