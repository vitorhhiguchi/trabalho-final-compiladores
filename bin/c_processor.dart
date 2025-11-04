import 'dart:io';
import 'package:antlr4/antlr4.dart';

// Importa os arquivos gerados pelo ANTLR
import '../lib/src/generated/CSubsetLexer.dart';
import '../lib/src/generated/CSubsetParser.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Erro: Nenhum arquivo de entrada fornecido.');
    stderr.writeln('Uso: dart run c_processor.dart <arquivo.c>');
    exit(1);
  }

  final inputFilePath = args[0];

  try {
    // 1️⃣ Lê o arquivo e cria um CharStream
    // Na runtime nova, CharStreams foi substituído por InputStream
    final input = await InputStream.fromPath(inputFilePath);

    // 2️⃣ Cria o Lexer
    final lexer = CSubsetLexer(input);

    // 3️⃣ Cria o fluxo de tokens
    final tokens = CommonTokenStream(lexer);

    // 4️⃣ Cria o Parser
    final parser = CSubsetParser(tokens);

    // 5️⃣ Define um listener de erro customizado
    parser.removeErrorListeners();
    parser.addErrorListener(MyErrorListener());

    // 6️⃣ Inicia a análise sintática a partir da regra raiz ("program")
    final tree = parser.program();

    // Se chegou até aqui, a análise ocorreu sem erros
    print('✅ Arquivo "$inputFilePath" analisado com sucesso!');
    print('Árvore sintática gerada:');
    print(tree.toStringTree());

  } catch (e, st) {
    stderr.writeln('❌ Erro ao processar o arquivo: $e');
    stderr.writeln(st);
    exit(1);
  }
}

// Listener personalizado de erros de sintaxe
class MyErrorListener extends BaseErrorListener {
  @override
  void syntaxError(
    Recognizer recognizer,
    Object? offendingSymbol,
    int? line,
    int? charPositionInLine,
    String msg,
    RecognitionException? e,
  ) {
    stderr.writeln('❌ Erro de Sintaxe na linha ${line ?? "?"}:${charPositionInLine ?? "?"} -> $msg');
    exit(1);
  }
}
