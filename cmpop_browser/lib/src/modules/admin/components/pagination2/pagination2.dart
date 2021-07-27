import 'dart:async';
import 'package:angular/angular.dart';
import 'package:cmpop_core/cmpop_core.dart';

@Component(
    selector: 'pagination-component',
    styleUrls: ['pagination2.css'],
    templateUrl: 'pagination2.html',
    directives: [coreDirectives],
    exports: [PaginationBtnType])
class Pagination2Component implements AfterChanges {
  List<PaginationModel> paginationItems = <PaginationModel>[];

  int _totalRecords = 0;

  @Input('totalRecords')
  set totalRecords(int v) {
    if (v != null) {
      _totalRecords = v;
    }
  }

  int get totalRecords => _totalRecords;

  Filtros _filtros = Filtros();

  @Input('filtros')
  set filtros(Filtros f) {
    if (f != null) {
      _filtros = f;
    }
  }

  Filtros get filtros => _filtros;

  int currentPage = 1;
  final int _btnQuantity = 5;
  PaginationType paginationType = PaginationType.carousel;

  final _onChangePageList = StreamController<Filtros>();
  @Output()
  Stream<Filtros> get onChange => _onChangePageList.stream;

  Pagination2Component() {
    /* _onChangePageList.stream.listen((event) {
      print('listen');
    });*/
  }

  void prevPage() {
    if (currentPage == 0) {
      return;
    }
    if (currentPage > 1) {
      currentPage--;
      changePage(currentPage);
    }
  }

  void nextPage() {
    if (currentPage == numPages) {
      return;
    }
    if (currentPage < numPages) {
      currentPage++;
      changePage(currentPage);
    }
  }

  void changePage(page) {
    getData();
    if (page != currentPage) {
      currentPage = page;
    }
  }

  void irParaUltimaPagina() {
    currentPage = numPages;
    changePage(currentPage);
  }

  void irParaPrimeiraPagina() {
    currentPage = 1;
    changePage(currentPage);
  }

  void getData() {
    var curPage = currentPage == 1 ? 0 : currentPage - 1;
    filtros.offset = curPage * filtros.limit;
    _onChangePageList.add(filtros);
    drawPagination();
  }

  int get numPages {
    var totalPages = (totalRecords / filtros.limit).ceil();
    return totalPages;
  }

  void drawPagination() {
    //quantidade total de paginas
    var totalPages = numPages;

    //quantidade de botões de paginação exibidos
    var btnQuantity = _btnQuantity > totalPages ? totalPages : _btnQuantity;
    //var currentPage = currentPage; //pagina atual
    //clear paginateContainer for new draws
    //self.paginateContainer?.innerHtml = '';
    paginationItems?.clear();
    var paginatePrevBtn = PaginationModel(btnType: PaginationBtnType.prev, onClick: prevPage);
    var paginateNextBtn = PaginationModel(btnType: PaginationBtnType.next, onClick: nextPage);
    paginationItems.add(paginatePrevBtn);

    if (totalRecords < filtros.limit) {
      return;
    }

    if (btnQuantity == 1) {
      return;
    }

    if (currentPage == 1) {
      paginatePrevBtn.disabled = true;
    }

    if (currentPage == totalPages) {
      paginateNextBtn.disabled = true;
    }

    var idx = 0;
    var loopEnd = 0;
    switch (paginationType) {
      case PaginationType.carousel:
        idx = (currentPage - (btnQuantity / 2)).toInt();
        if (idx <= 0) {
          idx = 1;
        }
        loopEnd = idx + btnQuantity;
        if (loopEnd > totalPages) {
          loopEnd = totalPages + 1;
          idx = loopEnd - btnQuantity;
        }
        while (idx < loopEnd) {
          var link = PaginationModel(btnType: PaginationBtnType.page);
          if (idx == currentPage) {
            link.active = true;
          }
          link.page = idx;
          link.label = idx.toString();
          link.onClick = () {
            if (currentPage != link.page) {
              currentPage = link.page;
              changePage(currentPage);
            }
          };
          paginationItems.add(link);
          idx++;
        }
        break;
      case PaginationType.cube:
        var facePosition = (currentPage % btnQuantity) == 0 ? btnQuantity : currentPage % btnQuantity;
        loopEnd = btnQuantity - facePosition + currentPage;
        idx = currentPage - facePosition;
        while (idx < loopEnd) {
          idx++;
          if (idx <= totalPages) {
            var link = PaginationModel(btnType: PaginationBtnType.page);
            if (idx == currentPage) {
              link.active = true;
            }
            link.page = idx;
            link.label = idx.toString();
            link.onClick = () {
              if (currentPage != link.page) {
                currentPage = link.page;
                changePage(currentPage);
              }
            };
            paginationItems.add(link);
          }
        }
        break;
    }
    paginationItems.add(paginateNextBtn);
  }

  @override
  void ngAfterChanges() {
    drawPagination();
    //print('Pagination2Component@ngAfterChanges ');
  }

  void update() {
    drawPagination();
  }
}
