import 'dart:async';
import 'dart:html' as html;
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:cmpop_browser/src/shared/app_config.dart';
import 'package:cmpop_browser/src/shared/components/menu_treeview/menu_treeview.dart';
import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:cmpop_browser/src/shared/components/simple_loading/simple_loading.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_browser/src/shared/repositories/backend_repository.dart';
import 'package:angular_components/material_select/material_dropdown_select.dart';

import 'package:cmpop_core/cmpop_core.dart';
import 'package:uuid/uuid.dart';

@Component(
    selector: 'cadastro-menu',
    styleUrls: ['cadastro_menu.css'],
    templateUrl: 'cadastro_menu.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
      materialInputDirectives,
      materialNumberInputDirectives,
      MaterialDropdownSelectComponent,
      MaterialInputComponent,
      MaterialButtonComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialDialogComponent,
      ModalComponent,
      MenuTreeViewComponent,
    ],
    providers: [overlayBindings],
    pipes: [TruncatePipe, commonPipes],
    exports: [])
class CadastroMenuComponent implements OnInit, OnActivate {
  final BackendRepository backendRepository;

  Menu menu;

  List<Menu> menus = <Menu>[];
  List<Pagina> paginas = <Pagina>[];
  bool showForm = false;
  bool showModalSelectMenuPai = false;
  bool isEditing = false;
  bool noContent = false;
  SimpleLoadingComponent loading;

  @ViewChild('container')
  html.DivElement container;

  @ViewChild('modalContainer')
  html.DivElement modalContainer;

  CadastroMenuComponent(this.backendRepository) {
    loading = SimpleLoadingComponent();
  }

  void initNewMenu() {
    menu = Menu(dataCadastro: DateTime.now());
  }

  Future<void> getAllPaginas() async {
    loading.show(target: container);
    try {
      var data = await backendRepository.getAllAsMap(AppConfig.PAGINAS);
      paginas.clear();
      data.forEach((element) {
        paginas.add(Pagina.fromMap(element));
      });
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e $s');
      print(e);
    } finally {
      loading.hide();
    }
  }

  Future<void> getAll() async {
    try {
      loading.show();
      var data = await backendRepository.getMenuHierarquia(filtrarAtivos: false);
      menus.clear();
      data.forEach((element) {
        menus.add(Menu.fromMap(element));
      });
    } catch (e, s) {
      noContent = true;
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e');
      print(s);
    } finally {
      loading.hide();
    }
  }

  void openModalForSetMenuPai() {
    showModalSelectMenuPai = true;
  }

  void editar(Menu e) {
    menu = e;
    var parents = menus?.where((m) => m.id == menu.idPai);
    menu.parent = menu.idPai != null && parents?.isNotEmpty == true ? parents.first : menu.parent;
    showForm = true;
    isEditing = true;
  }

  void deletar(Menu m) {
    SimpleDialogComponent.showConfirm('Tem certeza?', confirmAction: () async {
      try {
        loading.show(target: container);
        await backendRepository.deleteAsMap(m.toMap(), AppConfig.MENUS);
        showForm = false;
        isEditing = false;
        await getAll();
      } catch (e, s) {
        SimpleDialogComponent.showAlert('Erro ao remover', subMessage: '$e');
        print(s);
      } finally {
        loading.hide();
      }
    });
  }

  void onSelectMenuPaiHandle(Menu e) {
    if (menu.id != e.id) {
      menu.parent = e;
      menu.idPai = e.id;
    }

    showModalSelectMenuPai = false;
  }

  void removeMenuPai(Menu m) {
    menu.parent = null;
    menu.idPai = 'null';
  }

  void adicionar() {
    showForm = true;
    isEditing = false;
    initNewMenu();
  }

  void cancelar() {
    showForm = false;
    isEditing = false;
  }

  void salvar() async {
    try {
      loading.show(target: modalContainer);
      if (isEditing) {
        await backendRepository.updateAsMap(menu.toMap(), AppConfig.MENUS);
      } else {
        menu.dataCadastro = DateTime.now();
        menu.id = Uuid().v4();
        await backendRepository.createAsMap(menu.toMap(), AppConfig.MENUS);
      }

      await getAll();
      showForm = false;
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao salvar', subMessage: '$e');
      print(s);
    } finally {
      loading.hide();
    }
  }

  void refresh() async {
    await getAll();
  }

  void deleteItem(Menu m, e) {
    SimpleDialogComponent.showConfirm('Tem certesa?', confirmAction: () async {
      try {
        loading.show();
        await backendRepository.deleteAsMap(m.toMap(), AppConfig.MENUS);
        menus.remove(m);
      } catch (e) {
        SimpleDialogComponent.showAlert('Erro ao remover', subMessage: '$e');
        print(e);
      } finally {
        loading.hide();
      }
    });
  }

  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState previous, RouterState current) async {
    await getAll();
    await getAllPaginas();
  }
}
