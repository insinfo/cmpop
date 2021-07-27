import 'dart:async';
import 'dart:html' as html;
import 'package:angular/angular.dart';
import 'package:cmpop_browser/src/shared/components/carousel/slide.dart';

/// Carousel component.
@Component(
  selector: 'carousel',
  templateUrl: 'carousel.html',
  styleUrls: ['carousel.css'],
  directives: [
    coreDirectives,
  ],
)
class CarouselComponent implements OnDestroy, AfterContentInit, AfterChanges, AfterViewInit {
  @ContentChildren(SlideComponent)
  List<SlideComponent> slides = [];
  var slideIndex = 1;

  @Input('autoPause')
  bool autoPause = true;

  @Input('interval')
  int interval = 2800;
  Timer timer;
  bool _isPaused = false;

  @Input('isStartStopped')
  bool isStartStopped = false;

  StreamController<dynamic> onInitStreamController = StreamController<dynamic>();

  @Output('onInit')
  Stream get onInit => onInitStreamController.stream;

  @override
  void ngAfterChanges() {}

  @override
  void ngAfterViewInit() {
    slides.forEach((p) => p.parent = this);

    if (!isStartStopped) {
      play();
    }

    onInitStreamController.add(true);
    /* if (html.document.querySelector('video') != null) {
      html.VideoElement video = html.document.querySelector('video');
      //oncanplaythrough
      video.onCanPlayThrough.listen((event) {
        video.muted = true;
        video.volume = 0;
        video.play();
        video.pause();
        video.play();

        print('CarouselComponent@reproduzVideoSeHouver video oncanplaythrough');
      });
    }*/
  }

  /* void reproduzVideoSeHouver() {
    print("CarouselComponent@reproduzVideoSeHouver ${html.document.querySelector('video')}");

    if (html.document.querySelector('video') != null) {
      html.VideoElement video = html.document.querySelector('video');
      video.muted = true;
      video.volume = 0;
      video.play();
      video.pause();
      video.play();
    }
  }*/

  @override
  void ngAfterContentInit() {
    Future.delayed(Duration(milliseconds: 200), () {
      //print(slides?.length);
      if (slides?.isNotEmpty == true) {
        slides.first.active = true;
      }
    });
  }

  void loop(Timer t) {
    plusSlides(1);
  }

  CarouselComponent();

  void mouseleavePlay() {
    if (_isPaused) {
      if (!isStartStopped) {
        play();
      }
    }
  }

  void play() {
    if (slides != null && slides.length > 1) {
      _isPaused = false;
      timer = Timer.periodic(Duration(milliseconds: interval), loop);
    }
  }

  void mouseenterPause() {
    if (autoPause) {
      _isPaused = true;
      timer?.cancel();
    }
  }

  void plusSlides(int n) {
    showSlides(slideIndex += n);
    // reproduzVideoSeHouver();
  }

  void setCurrentSlide(int n) {
    showSlides(slideIndex = n + 1);
  }

  void showSlides(int n) {
    var i = 0;

    if (n > slides.length) {
      slideIndex = 1;
    }
    if (n < 1) {
      slideIndex = slides.length;
    }
    for (i = 0; i < slides.length; i++) {
      slides[i].active = false;
    }
    var dots = html.document.querySelectorAll('.dot');
    if (dots is List<html.HtmlElement>) {
      for (i = 0; i < dots.length; i++) {
        dots[i].className = dots[i].className.replaceAll(' active', '');
      }
      dots[slideIndex - 1].className += ' active';
    }
    if (slides?.isNotEmpty == true) {
      slides[slideIndex - 1].active = true;
    }
  }

  @override
  void ngOnDestroy() {
    timer?.cancel();
  }
}
