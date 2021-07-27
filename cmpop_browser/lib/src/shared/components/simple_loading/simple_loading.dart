import 'dart:html' as html;

class SimpleLoadingComponent {
  List<html.DivElement> loadings = <html.DivElement>[];
  html.HtmlElement _target;
  int requisicoes = 0;
  //Uuid uniqueIdGen;
  static SimpleLoadingComponent instance;
  static SimpleLoadingComponent getInstance() {
    instance ??= SimpleLoadingComponent();
    return instance;
  }

  var template = ''' 
    <style>
      .lds-roller {
      display: inline-block;
      position: relative;
      width: 80px;
      height: 80px;
      }
      .lds-roller div {
      animation: lds-roller 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
      transform-origin: 40px 40px;
      }
      .lds-roller div:after {
      content: " ";
      display: block;
      position: absolute;
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: #fff;
      margin: -4px 0 0 -4px;
      }
      .lds-roller div:nth-child(1) {
      animation-delay: -0.036s;
      }
      .lds-roller div:nth-child(1):after {
      top: 63px;
      left: 63px;
      }
      .lds-roller div:nth-child(2) {
      animation-delay: -0.072s;
      }
      .lds-roller div:nth-child(2):after {
      top: 68px;
      left: 56px;
      }
      .lds-roller div:nth-child(3) {
      animation-delay: -0.108s;
      }
      .lds-roller div:nth-child(3):after {
      top: 71px;
      left: 48px;
      }
      .lds-roller div:nth-child(4) {
      animation-delay: -0.144s;
      }
      .lds-roller div:nth-child(4):after {
      top: 72px;
      left: 40px;
      }
      .lds-roller div:nth-child(5) {
      animation-delay: -0.18s;
      }
      .lds-roller div:nth-child(5):after {
      top: 71px;
      left: 32px;
      }
      .lds-roller div:nth-child(6) {
      animation-delay: -0.216s;
      }
      .lds-roller div:nth-child(6):after {
      top: 68px;
      left: 24px;
      }
      .lds-roller div:nth-child(7) {
      animation-delay: -0.252s;
      }
      .lds-roller div:nth-child(7):after {
      top: 63px;
      left: 17px;
      }
      .lds-roller div:nth-child(8) {
      animation-delay: -0.288s;
      }
      .lds-roller div:nth-child(8):after {
      top: 56px;
      left: 12px;
      }
      @keyframes lds-roller {
      0% {
        transform: rotate(0deg);
      }
      100% {
        transform: rotate(360deg);
      }
      }
    </style>     
    
            <div class="lds-roller"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>
      
     
    ''';

  SimpleLoadingComponent() {
    // uniqueIdGen = Uuid();
  }

  void show({html.HtmlElement target}) {
    _target = target;

    var loading = html.DivElement();
    loading.style.zIndex = '1011';

    loading.style.display = 'flex';
    loading.style.alignItems = 'center';
    loading.style.justifyContent = 'center';
    loading.style.border = '0';
    loading.style.margin = '0';
    loading.style.padding = '0';
    loading.style.top = '0';
    loading.style.left = '0';
    loading.style.background = 'rgb(62 60 60 / 53%)';
    loading.style.cursor = 'default';
    loading.classes.add('SimpleLoadingComponent');

    if (_target == null) {
      loading.style.width = '100vw';
      loading.style.height = '100vh';
      loading.style.position = 'fixed';
    } else {
      loading.style.position = 'absolute';
      loading.style.width = '100%';
      loading.style.height = '100%';
    }

    loading.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);

    if (_target == null) {
      html.document.querySelector('body').append(loading);
    } else {
      _target.append(loading);
    }
    loadings.add(loading);
    requisicoes++;
  }

  void hide() {
    if (loadings.isNotEmpty) {
      requisicoes--;
      loadings.last.remove();
      loadings.removeLast();
    }
  }
}
