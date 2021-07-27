import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

import 'package:cmpop_browser/src/shared/components/carousel/carousel.dart';
import 'package:cmpop_browser/src/shared/components/carousel/slide.dart';
import 'package:cmpop_browser/src/shared/components/simple_dialog/simple_dialog.dart';
import 'package:cmpop_browser/src/shared/components/simple_loading/simple_loading.dart';
import 'package:cmpop_browser/src/shared/exceptions/no_content_exception.dart';
import 'package:cmpop_browser/src/shared/pipes/truncate_pipe.dart';
import 'package:cmpop_browser/src/shared/repositories/backend_repository.dart';
import 'dart:html' as html;

import 'package:cmpop_browser/src/shared/services/header_footer_service.dart';

import 'package:cmpop_browser/src/shared/utils/utils.dart';

@Component(
    selector: 'home',
    styleUrls: [
      'home_page.css',
      'package:angular_components/app_layout/layout.scss.css',
    ],
    templateUrl: 'home_page.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
      CarouselComponent,
      SlideComponent,
    ],
    pipes: [TruncatePipe]) //extends Object with CanReuse
class HomePage implements OnDeactivate, OnInit, OnActivate, OnDestroy {
  final BackendRepository backendRepository;
  final HeaderFooterService headerFooterService;

  @ViewChild('container')
  html.DivElement container;

  SimpleLoadingComponent loading;
  bool noContent = false;
  bool isLoading = true;
  StreamSubscription streamSubscriptionChangeIdioma;

  var fakeList = List.generate(14, (int index) => index * index);

  HomePage(this.backendRepository, this.headerFooterService) {
    //esconde fundo menu horizontal
    headerFooterService.showBackground = false;
    loading = SimpleLoadingComponent();
  }

  @override
  void onDeactivate(RouterState current, RouterState next) {
    //exibe fundo menu horizontal
    headerFooterService.showBackground = true;
  }

  Future<void> getHomeOptions() async {
    try {
      isLoading = true;
    } on NoContentException {
      noContent = true;
    } catch (e, s) {
      SimpleDialogComponent.showAlert('Erro ao buscar os dados', subMessage: '$e');
      print('HomePage@getHomeOptions $e $s');
    } finally {
      isLoading = false;
    }
  }

  @override
  void ngOnInit() async {
    await getHomeOptions();

    print('Home@ngOnInit()');
  }

  /*@override
  Future<bool> canReuse(RouterState current, RouterState next) {
    return super.canReuse(current, next);
  }*/

  @override
  void onActivate(RouterState previous, RouterState current) async {
    html.window.scrollTo(0, 0);
  }

  @override
  void ngOnDestroy() {
    streamSubscriptionChangeIdioma?.cancel();
  }

  void irParaBaixo() {
    Utils.irParaAncora('.segmento');
  }
}
