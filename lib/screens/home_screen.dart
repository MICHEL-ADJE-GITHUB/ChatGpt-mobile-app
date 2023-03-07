import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import 'package:typewritertext/typewritertext.dart';
import '../services/network.dart';
import '../utilities/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isLoading;
  TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  FetchApiData ApiData = FetchApiData();


  @override
  void initState() {
    super.initState();
    isLoading = false;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT by Michel Adje'),
        centerTitle: true,
        backgroundColor: kBgColor,
      ),
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Expanded(child: _buildList()),
          // le circularProgressIndicator apparaitra pendant le chargement de la réponse du bot
          // et il sera gerer par le bool isLoading initialisé par défaut à false dans l'initState
          Visibility(
            visible: isLoading,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                // chat body
                // l'input de saisie de l'user et le btn d'envoi
                _buildInput(),
                // Le bouton d'envoi
                _buildSubmit(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: Colors.white),
        controller: _textController,
        decoration: InputDecoration(
          fillColor: Colors.grey[600],
          filled: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
        visible: !isLoading,
        child: Container(
          color: Colors.grey[600],
          child: IconButton(
            onPressed: () {
              // afficher l'entrée de l'utilisateur
              setState(() {
                _messages.add(ChatMessage(
                    text: _textController.text,
                    chatMessageType: ChatMessageType.user));
                isLoading = true;
              });
              // on recupere la saisie de l'user au sein d'une variable et on vide le texfield
              var input = _textController.text;
              _textController.clear();
              Future.delayed(Duration(microseconds: 50))
                  .then((value) => _scrollDown());

              //API Call
              ApiData.GenerateResponse(input).then((value) => {
                    setState(() {
                      isLoading = false;
                      // affiche la reponse du bot
                      _messages.add(ChatMessage(
                          text: value.trim(),
                          chatMessageType: ChatMessageType.bot));
                    })
                  });
              _textController.clear();
              Future.delayed(Duration(microseconds: 50))
                  .then((value) => _scrollDown());
            },
            icon: Icon(
              Icons.send_rounded,
              color: Colors.white,
            ),
          ),
        ));
  }

  // _scrollDown est une fontion qui permet d'animer le scrolling apres l'entrée de l'utilisateur
  void _scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  ListView _buildList() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _messages.length,
        controller: _scrollController,
        itemBuilder: ((context, index) {
          var message = _messages[index];
          return ChatMessageWidget(
            text: message.text,
            chatMessageType: message.chatMessageType,
          );
        }));
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(15),
      color:
          chatMessageType == ChatMessageType.bot ? kbotBgColor : kUserBgColor,
      child: chatMessageType == ChatMessageType.bot
          ? Row(
              children: [
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: TypeWriterText(
                            maintainSize: false,
                            text: Text(
                              text,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            duration: Duration(milliseconds: 50),
                          ),
                        )
                      ],
                    )),
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'images/openAi.png',
                      scale: 1.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'images/user.jpg',
                      scale: 1.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    )
                  ],
                ))
              ],
            ),
    );
  }
}
