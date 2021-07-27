import 'dart:html';
import 'package:angular/angular.dart';

@Directive(selector: '[midiaPreviewDirective]')
class MidiaPreviewDirective implements AfterViewInit, AfterChanges, OnDestroy {
  // @Input('midiaPreviewDirective')
  // String valorPassador;

  @override
  void ngAfterChanges() {}

  @override
  void ngAfterViewInit() {
    _handleEvent();
  }

  HtmlElement _host;

  MidiaPreviewDirective(HtmlElement element) {
    if (element is ImageElement || element is VideoElement) {
      _host = element;
    } else {
      throw Exception('MidiaPreviewDirective não pode se atribuida a um elemento diferente de IMG ou Video');
    }
  }

  void _handleEvent() {
    var shadow = DivElement();
    shadow.style.position = 'absolute';
    shadow.style.top = '5px';
    shadow.style.right = '6px';
    shadow.style.background = 'rgb(0 0 0 / 42%)';
    shadow.style.width = '30px';
    shadow.style.height = '30px';
    shadow.style.borderRadius = '6px';
    _host.parent.append(shadow);

    var btn = ButtonElement();
    //btn.classes.add('icon-container');
    btn.style.position = 'absolute';
    btn.style.top = '5px';
    btn.style.right = '5px';
    btn.style.background = 'none';
    btn.style.width = '30px';
    btn.style.height = '30px';
    btn.style.border = 'none';
    btn.style.color = 'white';
    //<i class="gg-maximize-alt"></i>
    var icon = document.createElement('i');
    icon.classes.addAll(['gg-maximize-alt']);
    /*icon.style.fontSize = '14px';
    icon.style.color = '#fff';
    icon.style.fontWeight = 'bold';*/

    btn.append(icon);
    _host.parent.append(btn);

    btn.onClick.listen((event) {
      maximizarItem();
    });
  }

  void maximizarItem() {
    //Midia midia, html.MouseEvent event
    //  event.stopPropagation();
    var divModal = DivElement();
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

    var divModalContent = DivElement();
    divModalContent.style.background = 'rgba(255, 255, 255, 0)';
    divModalContent.style.width = '85%';
    //divModalContent.style.height = 'calc(100vh - 100px)';
    divModalContent.style.height = '85%';

    if (_host is ImageElement) {
      var img = ImageElement();
      img.src = (_host as ImageElement).src;
      img.style.width = '100%';
      img.style.height = '100%';
      img.style.objectFit = 'contain';
      divModalContent.append(img);
      img.onClick.listen((event) {
        //event.stopPropagation();
      });
    } else if (_host is VideoElement) {
      var video = VideoElement();
      video.src = (_host as VideoElement).src;
      video.style.width = '100%';
      video.style.height = '100%';
      video.style.outline = 'none';
      video.controls = true;
      video.muted = true;
      video.autoplay = true;
      divModalContent.append(video);
    }
    /*else {
      var iframe = IFrameElement();
      iframe.src = midia.link;
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.style.border = 'none';
      iframe.style.outline = 'none';
      divModalContent.append(iframe);
    }*/

    divModal.append(divModalContent);

    var btnClose = ButtonElement();
    btnClose.text = '+';
    btnClose.style.position = 'fixed';
    btnClose.style.transform = 'rotate(45deg)';
    btnClose.style.zIndex = '5001';
    btnClose.style.right = '19px';
    btnClose.style.top = '3px';
    btnClose.style.background = 'transparent';
    btnClose.style.border = 'none';
    btnClose.style.padding = '0';
    btnClose.style.margin = '0';
    btnClose.style.color = 'white';
    btnClose.style.fontSize = '30px';

    btnClose.onClick.listen((event) {
      divModal.remove();
    });
    divModal.append(btnClose);

    divModal.onClick.listen((event) {
      //divModal.remove();
    });
    document.body.append(divModal);
  }

  @override
  void ngOnDestroy() {}
}
