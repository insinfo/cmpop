import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular/security.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:cmpop_browser/src/shared/components/simple_loading/simple_loading.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_browser/src/shared/repositories/midia_repository.dart';
import 'package:cmpop_core/cmpop_core.dart';

import 'dart:html' as html;

import 'package:uuid/uuid.dart';

@Component(
  selector: 'galeria',
  styleUrls: ['galeria.css'],
  templateUrl: 'galeria.html',
  directives: [
    routerDirectives,
    formDirectives,
    coreDirectives,
    MaterialDialogComponent,
    ModalComponent,
  ],
  pipes: [commonPipes, TruncatePipe],
  providers: <dynamic>[materialProviders],
)
class GaleriaComponent implements OnInit, OnActivate {
  final DomSanitizationService sanitizer;
  bool showModal = false;
  bool isEditing = false;
  bool isSelectAll = false;
  List<Midia> midias = <Midia>[];
  Midia midiaSelected = Midia();
  Filtro filtro = Filtro(limit: 20, offset: 0);
  Midia singleSelected;
  SimpleLoadingComponent loading;
  final MidiaRepository midiaRepository;
  int maxImageSize = 1024;
  bool resizeImage = true;

  @Input('onModal')
  bool onModal = false;

  @Input('isSingleSelect')
  bool isSingleSelect = false;

  @ViewChild('container')
  html.DivElement container;

  @ViewChild('modalContainer')
  html.DivElement modalContainer;

  @ViewChild('select')
  html.SelectElement selectItemsPerPage;

  @ViewChild('inputSearch')
  html.InputElement inputSearch;

  GaleriaComponent(this.midiaRepository, this.sanitizer) {
    loading = SimpleLoadingComponent();
  }

  void refresh() {
    filtro.limit = 20;
    filtro.offset = 0;
    filtro.searchText = '';
    selectItemsPerPage.options.firstWhere((e) => e.value == '20').selected = true;
    inputSearch.value = '';

    getAll();
  }

  void itemsPerPageChange(html.SelectElement sel) {
    filtro.limit = int.tryParse(sel.value);
    getAll();
  }

  void searchEnterHandle(value) {
    filtro.searchText = value;
    getAll();
  }

  void backPage() {
    if (filtro.offset > 0) {
      filtro.offset -= filtro.limit;
      getAll();
    }
  }

  void nextPage() {
    filtro.offset += filtro.limit;
    getAll();
  }

  Future<void> getAll() async {
    loading.show(target: container);
    try {
      var data = await midiaRepository.all(filtro: filtro);
      midias.clear();
      data.forEach((element) {
        midias.add(Midia.fromMap(element));
      });
      loading.hide();
    } catch (e, s) {
      loading.hide();
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e');
      print('GaleriaComponent@getAll $e $s');
    }
  }

  void salvar() async {
    try {
      loading.show(target: modalContainer);

      if (!isEditing) {
        midiaSelected.dataCadastro = DateTime.now();
        midiaSelected.id = Uuid().v4();
        await midiaRepository.create(midiaSelected, resizeImage: resizeImage, maxImageSize: maxImageSize);
      } else {
        await midiaRepository.update(midiaSelected, resizeImage: resizeImage, maxImageSize: maxImageSize);
      }

      showModal = false;
      loading.hide();
      await getAll();
    } catch (e) {
      loading.hide();
      SimpleDialogComponent.showAlert('Erro ao salvar', subMessage: '$e');
      print(e);
    }
  }

  void cancelar() {
    showModal = false;
  }

  void openAddModal() {
    midiaSelected = Midia();
    isEditing = false;
    showModal = true;
  }

  void handleFileUpload(html.FileList files) {
    /* if (midiaSelected.title == null || midiaSelected.title?.trim()?.isEmpty == true) {
      midiaSelected.title = files[0].name;
    }*/
    midiaSelected.file = files[0];
    midiaSelected.originalFilename = files[0].name;
    midiaSelected.mimeType = files[0].type;
  }

  void deleteItem(Midia midia, html.MouseEvent event) {
    event.stopPropagation();
    SimpleDialogComponent.showConfirm('Tem certeza?', confirmAction: () async {
      try {
        loading.show(target: container);
        await midiaRepository.deleteMidiaById(midia.id);
        loading.hide();
        await getAll();
      } catch (e) {
        loading.hide();
        SimpleDialogComponent.showAlert('Erro ao deletar', subMessage: '$e');
        print(e);
      }
    });
  }

  void editItem(Midia midia, html.MouseEvent event) {
    event.stopPropagation();
    midiaSelected = midia;
    isEditing = true;
    showModal = true;
  }

  void maximizarItem(Midia midia, html.MouseEvent event) {
    event.stopPropagation();
    var divModal = html.DivElement();
    divModal.style.background = 'rgba(0, 0, 0, 0.7)';
    divModal.style.position = 'fixed';
    divModal.style.width = '100vw';
    divModal.style.height = '100vh';
    divModal.style.zIndex = '5000';
    divModal.style.left = '0';
    divModal.style.top = '0';
    divModal.style.display = 'flex';
    divModal.style.justifyContent = 'center';
    divModal.style.alignItems = 'center';
    divModal.style.overflowY = 'auto';

    var divModalContent = html.DivElement();
    divModalContent.style.background = 'rgba(255, 255, 255, 0)';
    divModalContent.style.width = '85%';
    //divModalContent.style.height = 'calc(100vh - 100px)';
    divModalContent.style.height = '85%';

    if (midia?.mimeType?.startsWith('image/') == true) {
      var img = html.ImageElement();
      img.src = midia.link;
      img.style.width = '100%';
      img.style.height = '100%';
      img.style.objectFit = 'contain';
      divModalContent.append(img);
      img.onClick.listen((event) {
        //event.stopPropagation();
      });
    } else if (midia?.mimeType?.startsWith('video/') == true) {
      var video = html.VideoElement();
      video.src = midia.link;
      video.style.width = '100%';
      video.style.height = '100%';
      video.style.outline = 'none';
      video.controls = true;
      video.muted = true;
      video.autoplay = true;
      divModalContent.append(video);
    } else {
      var iframe = html.IFrameElement();
      iframe.src = midia.link;
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.style.border = 'none';
      iframe.style.outline = 'none';
      divModalContent.append(iframe);
    }

    divModal.append(divModalContent);

    var btnClose = html.ButtonElement();
    btnClose.text = 'x';
    btnClose.style.position = 'fixed';
    btnClose.style.zIndex = '5001';
    btnClose.style.right = '19px';
    btnClose.style.top = '9px';
    btnClose.style.background = 'transparent';
    btnClose.style.border = 'none';
    btnClose.style.padding = '0';
    btnClose.style.margin = '0';
    btnClose.style.color = 'white';
    btnClose.style.fontSize = '20px';
    //btnClose.style.transform = 'rotate(45deg)';
    btnClose.onClick.listen((event) {
      divModal.remove();
    });
    divModal.append(btnClose);

    divModal.onClick.listen((event) {
      //divModal.remove();
    });
    html.document.body.append(divModal);
  }

  final _onMultiSelectController = StreamController<List<Midia>>();
  @Output('onMultiSelect')
  Stream<List<Midia>> get onMultiSelect => _onMultiSelectController.stream;

  final _onSelectController = StreamController<Midia>();
  @Output('onSelect')
  Stream<Midia> get onSelect => _onSelectController.stream;

  Midia lastSelected;

  void selectMidia(Midia midia) {
    midia.isSelected = !midia.isSelected;
    singleSelected = midia;

    if (isSingleSelect) {
      lastSelected?.isSelected = false;
      lastSelected = midia;
      _onSelectController.add(singleSelected);
    } else {
      _onMultiSelectController.add(getAllSelected());
    }
  }

  List<Midia> getAllSelected() {
    var allSelected = <Midia>[];
    midias.forEach((m) {
      if (m.isSelected) {
        allSelected.add(m);
      }
    });

    return allSelected;
  }

  void clearSelections() {
    midias.forEach((m) => m.isSelected = false);
  }

  void toogleSelectAll() {
    isSelectAll = !isSelectAll;
    midias.forEach((m) {
      if (isSelectAll) {
        m.isSelected = true;
      } else {
        m.isSelected = false;
      }
    });
    _onMultiSelectController.add(getAllSelected());
  }

  @override
  void ngOnInit() {
    if (onModal) {
      getAll();
    }
  }

  @override
  void onActivate(RouterState previous, RouterState current) {
    getAll();
  }
}
