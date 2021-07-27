import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:cmpop_browser/src/shared/app_config.dart';
import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:cmpop_browser/src/shared/components/simple_loading/simple_loading.dart';

import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_browser/src/shared/repositories/backend_repository.dart';
import 'package:cmpop_core/cmpop_core.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

@Component(
    selector: 'cadastro-usuario',
    styleUrls: ['package:angular_components/app_layout/layout.scss.css', 'cadastro_usuario.css'],
    templateUrl: 'cadastro_usuario.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
      MaterialButtonComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialDialogComponent,
      ModalComponent,
    ],
    providers: [overlayBindings],
    pipes: [TruncatePipe, commonPipes])
class CadastroUsuarioComponent implements OnInit, OnActivate {
  final BackendRepository backendRepository;

  Usuario usuario = Usuario();
  List<Usuario> usuarios = <Usuario>[];
  bool showModal = false;
  bool showDialog = false;
  bool isEditing = false;
  SimpleLoadingComponent loading;

  @ViewChild('container')
  html.DivElement container;

  @ViewChild('modalContainer')
  html.DivElement modalContainer;

  CadastroUsuarioComponent(this.backendRepository) {
    loading = SimpleLoadingComponent();
  }

  void refresh() {
    getAll();
  }

  Future<void> getAll() async {
    loading.show(target: container);
    try {
      usuarios.clear();
      var data = await backendRepository.getAllAsMap(AppConfig.USUARIO);
      data.forEach((element) {
        usuarios.add(Usuario.fromMap(element));
      });
    } catch (e) {
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e');
      print(e);
    }
    loading.hide();
  }

  void adicionar() {
    showModal = true;
    isEditing = false;
    usuario = Usuario();
  }

  void editar(Usuario u) {
    usuario = u;
    showModal = true;
    isEditing = true;
  }

  void remover() async {
    loading.show(target: container);
    try {
      await backendRepository.deleteAsMap(usuario.toMap(), AppConfig.USUARIO);
      usuarios.remove(usuario);
      loading.hide();
      showModal = false;
      showDialog = false;
    } catch (e) {
      SimpleDialogComponent.showAlert('Erro ao remover', subMessage: '$e');
      print(e);
    }
  }

  void salvar() async {
    loading.show(target: modalContainer);
    try {
      if (isEditing) {
        await backendRepository.updateUsuarioByUsername(usuario);
      } else {
        if (usuarioExiste(usuario)) {
          SimpleDialogComponent.showAlert('Usuário já existe');
        } else {
          usuario.dataCadastro = DateTime.now();
          usuario.id = Uuid().v4();
          await backendRepository.criaUsuario(usuario);
          usuarios.add(usuario);
        }
      }
      showModal = false;
    } catch (e) {
      SimpleDialogComponent.showAlert('Erro ao salvar', subMessage: '$e');
      print(e);
    }
    loading.hide();
  }

  void cancelar() {
    showModal = false;
    isEditing = false;
  }

  void prepararExclusao(Usuario u) {
    usuario = u;
    showDialog = true;
  }

  bool usuarioExiste(Usuario usuario) {
    for (var u in usuarios) {
      if (u.username == usuario.username) {
        return true;
      }
    }
    return false;
  }

  @override
  void ngOnInit() {}

  @override
  void onActivate(RouterState previous, RouterState current) async {
    await getAll();
  }
}
