import 'package:contador_estoque/controller/home_page_controler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contador_estoque/data/bancoHelper.dart';
import 'package:contador_estoque/data/itens.dart';
import 'package:get/get.dart';
import 'package:contador_estoque/widgets/home_widgets.dart';
import 'dart:async';
import 'package:contador_estoque/screens/Add Item.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:contador_estoque/data/text.dart';
import 'package:flutter/foundation.dart';

class ListaDeProdutos extends StatefulWidget {
  ListaDeProdutos({Key key, this.titulo,this.storage}) : super(key: key);
  final String titulo;
  final fileTransfer storage;

  @override
  _ListaDeprodutosState createState() => _ListaDeprodutosState();
}

class _ListaDeprodutosState extends State<ListaDeProdutos> {
  _ListaDeprodutosState() {
    Get.put(HomePageController());
  }

  final _ccodigo = TextEditingController();
  final _cnome = TextEditingController();
  final _ccodbar = TextEditingController();
  final _cqtd = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  static DatabaseHelper banco;

  int qtdListaPesquisa = 0;
  List<Itens> listaDeProdutos;
  List<Itens> listaPesquisa;
  bool isSearching = false;
  bool isInList = false;

  @override
  void initState() {
    banco = DatabaseHelper();
    banco.inicializaBanco();

    Future<List<Itens>> listaDeProdutos = banco.getListaDeProdutos();
    listaDeProdutos.then((novaListaDeProdutos) {
      setState(() {
        this.listaDeProdutos = novaListaDeProdutos;
        this.listaPesquisa = novaListaDeProdutos;
        this.qtdListaPesquisa = novaListaDeProdutos.length;
      });
    });
  }

  _carregarLista() {
    banco = DatabaseHelper();
    banco.inicializaBanco();
    Future<List<Itens>> noteListFuture = banco.getListaDeProdutos();
    noteListFuture.then((novaListaDeProdutos) {
      setState(() {
        this.listaDeProdutos = novaListaDeProdutos;
        this.listaPesquisa = novaListaDeProdutos;
        this.qtdListaPesquisa = novaListaDeProdutos.length;
      });
    });
  }

  _ordenarPorNome() {
    setState(() {
      banco.ordenarNome();
    });
  }

  testePercorrer() {
    for (var i = 0; i < qtdListaPesquisa; i++) {
      print(
          "${listaDeProdutos[i].NomeProd} | ${listaDeProdutos[i].CodBar} | ${listaDeProdutos[i].QtdProd}");
    }
  }

  Future <File> escreverArquivo(){
    for(var i = 0;i<qtdListaPesquisa;i++){
      dynamic linha = "${listaPesquisa[i].NomeProd} | ${listaPesquisa[i].CodBar} | ${listaPesquisa[i].QtdProd}";
      //return widget.storage.writeFile(linha);
    }
    return widget.storage.writeFile(listaPesquisa[1].NomeProd);

    //Get.snackbar('Exportado','Itens exportado com sucesso!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff18203d),
        title: !isSearching
            ? TextButton(
                child: Text(
                  "Contador de Estoque",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    this.isSearching = false;
                    listaPesquisa = listaDeProdutos;
                  });
                },
              )
            : TextField(
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  _filterItens(value);
                },
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: "Procure o item aqui",
                    hintStyle: TextStyle(color: Colors.white)),
              ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      listaPesquisa = listaDeProdutos;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                )
        ],
        centerTitle: true,
      ),
      body: _listaDeProdutos(),
      backgroundColor: Color(0xff232c51),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xff18203d),
        shape: CircularNotchedRectangle(),
        child: Row(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
            IconButton(
                icon: Image.asset('assets/icon.png',
                    width: 25, color: Colors.white),
                onPressed: () {
                  Get.find<HomePageController>().escanearCodigoBarras();
                  if (Get.find<HomePageController>()
                      .valorCodigoBarras
                      .isEmpty) {
                    Get.snackbar(
                        "Vazio", "Não consegui ler o codigo. Tente novamente");
                    Get.to('/');
                  } else {
                    _verificarCodBar();
                  }
                }),
            Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 0)),
            GestureDetector(
              onTap: () => _ordenarN(Itens),
              onLongPress: () => _ordenarI(Itens),
              child: Icon(
                Icons.sort_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            Spacer(),
            IconButton(
                icon: Icon(Icons.description_rounded),
                color: Colors.white,
                onPressed: () {
                  escreverArquivo();
                }),
            Padding(padding: EdgeInsets.fromLTRB(10, 0, 8, 0)),
            IconButton(
                icon: Icon(Icons.restore, size: 27),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    banco.zerarQtd();
                    listaPesquisa = listaDeProdutos;
                    _carregarLista();
                    Get.snackbar("Zerado", "Estoque foi zerado com sucesso");
                  });
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 255, 136, 34),
        child: Icon(Icons.add),
        onPressed: () {
          _adicionarProduto();
          //Get.to(() => AddItem());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _removerItem(Itens itens, int index) {
    setState(() {
      listaDeProdutos = List.from(listaDeProdutos)..removeAt(index);
      banco.apagarProduto(itens.id);
      qtdListaPesquisa -= 1;
      Get.snackbar("Removido", "Item removido com Sucesso!");
    });
  }

  void _ordenarN(Itens) {
    setState(() {
      listaPesquisa = List.from(listaPesquisa)
        ..sort((a, b) => a.NomeProd.compareTo(b.NomeProd));
      banco.ordenarNome();
    });
  }

  void _ordenarI(Itens) {
    setState(() {
      listaPesquisa = List.from(listaPesquisa)
        ..sort((a, b) => a.id.compareTo(b.id));
      banco.ordenarId();
    });
  }

  void _filterItens(value) {
    setState(() {
      listaPesquisa = listaDeProdutos
          .where((Itens) =>
              Itens.NomeProd.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _verificarCodBar() {
    String valor = Get.find<HomePageController>().valorCodigoBarras;
    listaPesquisa = listaDeProdutos
        .where(
            (Itens) => Itens.CodBar.toLowerCase().contains(valor.toLowerCase()))
        .toList();
    if (listaPesquisa.length == 0 || listaPesquisa.isEmpty) {
      _adicionarProdutoCod();
    } else {
      setState(() {
        listaPesquisa = listaDeProdutos
            .where((Itens) =>
                Itens.CodBar.toLowerCase().contains(valor.toLowerCase()))
            .toList();
      });
    }
  }

  void _adicionarProduto() {
    _ccodigo.text = '';
    _cnome.text = '';
    _ccodbar.text = '';
    _cqtd.text = '';
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xff232c51),
            title: Text(
              "Novo Produto",
              style: TextStyle(color: Colors.white),
            ),
            content: Container(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: campoCodigo(_ccodigo),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 10,
                        ),
                        Flexible(
                          child: campoNome(_cnome),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 10,
                        ),
                        Flexible(
                          child: campoCodBar(_ccodbar),
                        ),
                        Divider(
                          height: 10,
                          color: Colors.transparent,
                        ),
                        Flexible(child: campoQtd(_cqtd)),
                      ],
                    ),
                  )),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Itens _itens;
                  if (_formkey.currentState.validate()) {
                    _itens = Itens(
                        _ccodigo.text, _cnome.text, _ccodbar.text, _cqtd.text);
                    banco.inserirProduto(_itens);
                    _carregarLista();
                    _formkey.currentState.reset();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  void _adicionarProdutoCod() {
    _ccodigo.text = '';
    _cnome.text = '';
    _ccodbar.text = Get.find<HomePageController>().valorCodigoBarras;
    _cqtd.text = '';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xff232c51),
            title: Text(
              "Novo Produto",
              style: TextStyle(color: Colors.white),
            ),
            content: Container(
              child: SingleChildScrollView(
                  child: Form(
                key: _formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: campoCodigo(_ccodigo),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 10,
                    ),
                    Flexible(
                      child: campoNome(_cnome),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 10,
                    ),
                    Flexible(
                      child: campoCodBar(_ccodbar),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.transparent,
                    ),
                    Flexible(child: campoQtd(_cqtd))
                  ],
                ),
              )),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Salvar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Itens _itens;
                  if (_formkey.currentState.validate()) {
                    _itens = Itens(
                        _ccodigo.text, _cnome.text, _ccodbar.text, _cqtd.text);
                    banco.inserirProduto(_itens);
                    _carregarLista();
                    _formkey.currentState.reset();
                    Navigator.of(context).pop();
                    Get.find<HomePageController>().zerarCodigo();
                  }
                },
              ),
            ],
          );
        });
  }

  void _atualizarProduto(Itens itens) {
    _ccodigo.text = itens.CodProd;
    _cnome.text = itens.NomeProd;
    _ccodbar.text = itens.CodBar;
    _cqtd.text = itens.QtdProd;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xff232c51),
            title: Text(
              "Atualizar Produto",
              style: TextStyle(color: Colors.white),
            ),
            content: Container(
              child: SingleChildScrollView(
                  child: Form(
                key: _formkey,
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: campoCodigo(_ccodigo),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 10,
                    ),
                    Flexible(
                      child: campoNome(_cnome),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 10,
                    ),
                    Flexible(
                      child: campoCodBar(_ccodbar),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.transparent,
                    ),
                    Flexible(child: campoQtd(_cqtd))
                  ],
                ),
              )),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Atualizar'),
                onPressed: () {
                  Itens _itens;
                  if (_formkey.currentState.validate()) {
                    _itens = Itens(
                        _ccodigo.text, _cnome.text, _ccodbar.text, _cqtd.text);
                    banco.atualizarProduto(_itens, itens.id);

                    _carregarLista();

                    _formkey.currentState.reset();

                    Navigator.of(context).pop();
                  }
                  Get.snackbar("Atualizado", "Item atualizado");
                },
              ),
            ],
          );
        });
  }


  Widget _listaDeProdutos() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: qtdListaPesquisa,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: ListTile(
            title: Row(
              children: <Widget>[
                // Daqui pra baixo, não tenho a minima noção de como esta funcionando.
                Expanded(
                    child: Text(
                  listaPesquisa[index].CodProd,
                  style: TextStyle(color: Colors.white),
                )),
                Expanded(
                    child: Text(
                      listaPesquisa[index].NomeProd,
                      style: TextStyle(color: Colors.white),
                    ),
                    flex: 2)
              ],
            ),
            subtitle: Text(
              listaPesquisa[index].CodBar,
              style: TextStyle(color: Colors.white),
            ),
            trailing: Text(
              listaPesquisa[index].QtdProd.toString(),
              style: TextStyle(color: Colors.white),
            ),
            leading: CircleAvatar(
              child: Text(listaPesquisa[index].NomeProd[0].toUpperCase()),
              backgroundColor: Color.fromARGB(255, 255, 136, 34),
              foregroundColor: Color(0xfffcfcfc),
            ),
          ),
          onLongPress: () => _removerItem(listaPesquisa[0], index),
          onTap: () => _atualizarProduto(listaPesquisa[index]),
        );
      },
    );
  }
}

Widget _Loading() {
  return Center(
    child: Wrap(
      alignment: WrapAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 10),
        Text('Loading...', style: TextStyle(fontSize: 20.0)),
      ],
    ),
  );
}
