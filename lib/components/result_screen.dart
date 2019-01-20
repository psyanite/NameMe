import 'dart:async';
import 'dart:math';

import 'package:crystal/components/home_screen.dart';
import 'package:crystal/locale/locales.dart';
import 'package:crystal/models/emoji.dart';
import 'package:crystal/models/name.dart';
import 'package:crystal/presentation/components.dart';
import 'package:crystal/presentation/theme.dart';
import 'package:crystal/state/app/app_state.dart';
import 'package:crystal/state/me/me_actions.dart';
import 'package:crystal/state/me/me_state.dart';
import 'package:crystal/utils/util.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:share/share.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (Store<AppState> store) => _Props.fromStore(store),
      builder: (context, props) => _Presenter(me: props.me, clearMe: props.clearMe, isCompact: props.isCompact, bodyFontSize: props.bodyFontSize, nameFontSize: props.nameFontSize));
  }
}

class _Presenter extends StatefulWidget {
  final MeState me;
  final Function clearMe;
  final bool isCompact;
  final double bodyFontSize;
  final double nameFontSize;

  _Presenter({this.me, this.clearMe, this.isCompact, this.nameFontSize, this.bodyFontSize});

  @override
  _PresenterState createState() => new _PresenterState();
}

class _PresenterState extends State<_Presenter> {
  Name name;
  String enBio;
  String localeBio;
  String languageCode;
  BannerAd _bannerAd;

  final double _bannerAdHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _bannerAd = Util.buildBannerAd()..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    languageCode = Localizations.localeOf(context).languageCode;
    if (widget.me.gender == null) return Scaffold();
    if (name != null) return _content(context);
    return FutureBuilder<Name>(
      future: getRandomName(widget.me.gender.name),
      builder: (context, AsyncSnapshot<Name> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Scaffold();
          case ConnectionState.done:
            if (snapshot.hasError) return Scaffold();
            name = snapshot.data;
            enBio = Util.getBio(widget.me, name.name, 'en');
            localeBio = languageCode != 'en' ? Util.getBio(widget.me, name.name, languageCode) : null;
            return _content(context);
        }
      });
  }

  Widget _content(BuildContext context) {
    _bannerAd..show();
    return Container(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(height: 10.0),
                _name(context),
                _bio(),
                _emojis(),
                _buttons(context),
              ],
            ),
          ),
        )),
      padding: EdgeInsets.only(bottom: _bannerAdHeight),
      color: Colors.grey[50],
    );
  }

  Widget _name(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: widget.isCompact ? 0.0 : 10.0),
          child: Text(AppLocalizations
            .of(context)
            .nameDesc, style: TextStyle(fontWeight: Burnt.fontLight)),
        ),
        Text(name.name, style: TextStyle(fontSize: widget.nameFontSize, fontWeight: Burnt.fontLight)),
        Container(height: 10.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(name.meaning, textAlign: TextAlign.center, style: TextStyle(fontSize: widget.bodyFontSize, fontWeight: Burnt.fontBold)),
        )
      ],
    );
  }

  Widget _bio() {
    getChildren(BuildContext context) {
      var children = <Widget>[
        Text(AppLocalizations.of(context).bioDesc, style: TextStyle(fontWeight: Burnt.fontLight)),
        Container(height: 10.0),
        Text(enBio, textAlign: TextAlign.center, style: TextStyle(fontSize: widget.bodyFontSize, fontWeight: Burnt.fontBold)),
      ];
      if (localeBio != null) {
        children.add(Container(height: 10.0));
        children.add(Text(localeBio, textAlign: TextAlign.center, style: TextStyle(fontSize: widget.bodyFontSize, fontWeight: Burnt.fontBold)));
      }
      return children;
    }
    return Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(children: getChildren(context))));
  }

  Widget _emojis() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_emoji(widget.me.animal), _emoji(widget.me.food), _emoji(widget.me.drink), _emoji(widget.me.scenery)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[_emoji(widget.me.weather), _emoji(widget.me.extras[0]), _emoji(widget.me.extras[1]), _emoji(widget.me.extras[2])]),
      ],
    );
  }

  Widget _emoji(Emoji emoji) {
    return Padding(padding: EdgeInsets.all(5.0), child: emoji.getImage(scale: 4.0));
  }

  Widget _buttons(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        BigButton(
          text: locale.shareButton,
          onPressed: () => _share(locale.shareMessage),
          fontColor: Colors.white,
          isGradient: true,
          isSpinnable: true,
        ),
        BigButton(
          text: locale.goAgainButton,
          onPressed: () {
            widget.clearMe();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
          borderColor: Burnt.primary,
          fontColor: Burnt.primary,
        ),
      ],
    );
  }

  void _share(String template) {
    const url = 'https://raw.githubusercontent.com/psyanite/crystal/master/app/assets/img/demo.jpg';
    var message = template.replaceAll(":name:", name.name).replaceAll(":meaning:", name.meaning).replaceAll(":en-bio:", enBio);
    if (message.contains(":locale-bio:")) message = message.replaceAll(":locale-bio:", localeBio);
    message = '$message \n\n $url';
    Share.share(message);
  }

  Future<Name> getRandomName(String gender) async {
    final lines = (await rootBundle.loadString('assets/names/$gender.csv')).split('\n');
    var details = lines[Random().nextInt(lines.length - 2) + 1].split('","');
    var meaning;
    switch (languageCode) {
      case 'en':
        meaning = details[1];
        break;
      case 'ko':
        meaning = details[2];
        break;
      case 'ja':
        meaning = details[3].replaceAll('\"\r', '');
        break;
    }
    return Name(
      name: details[0].replaceAll('"', ''),
      meaning: meaning,
    );
  }
}

class _Props {
  final MeState me;
  final Function clearMe;
  final bool isCompact;
  final double nameFontSize;
  final double bodyFontSize;

  _Props({this.me, this.clearMe, this.isCompact, this.nameFontSize, this.bodyFontSize});

  static fromStore(Store<AppState> store) {
    var isCompact = store.state.me.mediaData.size.height < 760.0;
    return _Props(
      me: store.state.me,
      clearMe: () => store.dispatch(ClearMe()),
      isCompact: isCompact,
      nameFontSize: isCompact ? 45.0: 58.0,
      bodyFontSize: isCompact ? 12.0 : 18.0,
    );
  }
}
