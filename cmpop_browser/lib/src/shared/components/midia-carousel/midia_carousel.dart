import 'dart:async';
import 'package:angular/angular.dart';
import 'dart:html' as html;

import 'package:cmpop_core/cmpop_core.dart';

@Component(
  selector: 'midia-carousel',
  templateUrl: 'midia_carousel.html',
  styleUrls: ['midia_carousel.css'],
  directives: [
    coreDirectives,
  ],
)
class MidiaCarouselComponent implements OnDestroy, AfterContentInit, AfterChanges, AfterViewInit {
  //variaveis
  String itemClassName = 'carousel__photo';
  var classes = ['initial', 'active', 'next', 'prev'];
  int currentSlide = 0;
  bool moving = true;
  int transitionDuration = 500; //millisecond (0.5s = 500ms)

  @Input('interval')
  int interval = 2800;

  Timer timer;
  bool _isPaused = false;

  @Input('autoPlay')
  bool autoPlay = true;

  @Input('pauseOnHover')
  bool pauseOnHover = true;

  @Input('showDots')
  bool showDots = true;

  @Input('midias')
  set inputMidias(List<Midia> mids) {
    midias.clear();
    if (mids != null) {
      midias.addAll(mids);
    }
  }

  List<Midia> midias = <Midia>[];

  int get totalItems => midias?.length;

  @ViewChild('carouselWrapper')
  html.DivElement carouselWrapper;

  @ViewChildren('divs')
  List<html.HtmlElement> items = <html.HtmlElement>[];
  //var streamItems =  Stream.fromIterable(items);

  MidiaCarouselComponent();

  @override
  void ngAfterChanges() {}

  @override
  void ngAfterViewInit() {
    initCarousel();
  }

  @override
  void ngAfterContentInit() {}

  void initCarousel() {
    setInitialClasses();
    // Set moving to false so that the carousel becomes interactive
    moving = false;

    if (autoPlay) {
      play();
    }
  }

  void play() {
    if (totalItems != null && totalItems > 1) {
      _isPaused = false;
      timer = Timer.periodic(Duration(milliseconds: interval), loop);
    }
  }

  void loop(Timer t) {
    moveNext(1);
  }

  void mouseleavePlay() {
    if (_isPaused) {
      if (autoPlay) {
        play();
      }
    }
  }

  void mouseenterPause() {
    if (pauseOnHover) {
      _isPaused = true;
      timer?.cancel();
    }
  }

  void setSlide(int i) {
    currentSlide = i;
    moveCarouselTo(i);
  }

  //As próximas duas funções definem as classes iniciais e adicionam
  //nossos ouvintes de eventos aos botões de navegação.

  // Set classes
  void setInitialClasses() {
    // Destina os itens anteriores, atuais e próximos
    // Isso pressupõe que haja pelo menos três itens.
    if (totalItems >= 3) {
      items[totalItems - 1].classes.add('prev');
      items[0].classes.add('active');
      items[1].classes.add('next');
    } else if (totalItems == 2) {
      items[0].classes.add('active');
      items[1].classes.add('next');
    } else if (totalItems == 1) {
      items[0].classes.add('active');
    }
  }

  // função de manipulador de navegação Próxima
  void moveNext(e) {
    // Verifique se está se movendo
    if (!moving) {
      // Se for o último slide, redefina para 0, senão +1
      if (currentSlide == (totalItems - 1)) {
        currentSlide = 0;
      } else {
        currentSlide++;
      }
      // Mova o carrossel para o slide atualizado
      moveCarouselTo(currentSlide);
    }
  }

  // Função do manipulador de navegação anterior
  void movePrev(e) {
    // Verifique se está se movendo
    if (!moving) {
      // If it's the first slide, set as the last slide, else -1
      if (currentSlide == 0) {
        currentSlide = (totalItems - 1);
      } else {
        currentSlide--;
      }
      // Move carousel to updated slide
      moveCarouselTo(currentSlide);
    }
  }

  void disableInteraction() {
    // Set 'moving' to true for the same duration as our transition.
    // (0.5s = 500ms)
    moving = true;
    // setTimeout runs its function once after the given time
    Timer(Duration(milliseconds: transitionDuration), () {
      moving = false;
    });
  }

  void moveCarouselTo(slide) {
    // Verifique se o carrossel está se movendo, se não, permita a interação
    if (!moving) {
      // desativa temporariamente a interatividade
      disableInteraction();
      // Testa se o carrossel tem mais de três itens
      //print('moveCarouselTo (totalItems - 1) > 3');
      if (totalItems > 3) {
        // Atualize os slides adjacentes antigos (old) com os novos (new)
        int newPrevious = slide - 1;
        int newNext = slide + 1;
        int oldPrevious = slide - 2;
        int oldNext = slide + 2;
        // Verifica e atualiza se os novos slides estão fora dos limites
        if (newPrevious <= 0) {
          oldPrevious = (totalItems - 1);
        } else if (newNext >= (totalItems - 1)) {
          oldNext = 0;
        }
        // Verifica e atualiza se o slide está no início / fim
        if (slide == 0) {
          newPrevious = (totalItems - 1);
          oldPrevious = (totalItems - 2);
          oldNext = (slide + 1);
        } else if (slide == (totalItems - 1)) {
          newPrevious = (slide - 1);
          newNext = 0;
          oldNext = 1;
        }
        // Agora que descobrimos onde estamos e para onde vamos,
        // adicionando / removendo classes, vamos acionar as transições.
        // Redefine os elementos next / prev antigos para

        //items[oldPrevious].className = itemClassName;
        //items[oldNext].className = itemClassName;
        items[oldPrevious].classes.removeAll(classes);
        items[oldNext].classes.removeAll(classes);
        // Add new classes
        /* items[newPrevious].className = itemClassName + ' prev';
        items[slide].className = itemClassName + ' active';
        items[newNext].className = itemClassName + ' next';*/
        updateClass(newPrevious, 'prev');
        updateClass(slide, 'active');
        updateClass(newNext, 'next');
      } else if (totalItems == 3) {
        var prevS = slide - 1;
        if (prevS == -1) {
          prevS = 2;
        }
        var currentS = slide;
        var nextS = slide + 1;
        if (nextS == totalItems) {
          nextS = 0;
        }

        updateClass(prevS, 'prev');
        updateClass(currentS, 'active');
        updateClass(nextS, 'next');
      } else if (totalItems == 2) {
        var prevS = slide == 0 ? 1 : 0;
        var currentS = slide;
        var nextS = slide == 1 ? 0 : 1;

        updateClass(prevS, 'prev');
        updateClass(currentS, 'active');
        updateClass(nextS, 'next');
      }
    }
  }

  void updateClass(int index, String classe) {
    items[index].classes.removeAll(classes);
    items[index].classes.add(classe);
  }

  @override
  void ngOnDestroy() {}
}
