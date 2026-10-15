// Editorial content for the settings reader. Replace here or publish an override
// through SettingsContentStore. Business/legal approval belongs before release.
class SettingsArticle {
  const SettingsArticle(
      {required this.heading,
      required this.introduction,
      required this.sections,
      this.questions = false});
  final String heading, introduction;
  final List<SettingsArticleSection> sections;
  final bool questions;
}

class SettingsArticleSection {
  const SettingsArticleSection(this.heading, this.body);
  final String heading, body;
}

const settingsArticles = <String, SettingsArticle>{
  'Privacy Policy': SettingsArticle(
      heading: 'Your information, your choices',
      introduction:
          'This policy explains the information associated with your Davochain account, why it is needed and how to raise a privacy request.',
      sections: [
        SettingsArticleSection('Account and identity information',
            'Account details include the name, email address and phone number you provide. Identity documents and verification information may be requested when a service requires an identity check. Keep your details accurate and update them when they change.'),
        SettingsArticleSection('Transactions and support',
            'Transaction records contain the assets, amounts, destinations, fees, references and status of your activity. Messages, attachments and other information you send to support help explain your request and investigate an issue.'),
        SettingsArticleSection('Device permissions',
            'Camera and photo access let you provide documents or gift-card images when needed. Notification permissions control device alerts. You can review these permissions in your device settings. Fingerprint access uses the authentication options available on your device.'),
        SettingsArticleSection('How information is used',
            'Information supports account access, verification, transaction processing, fraud prevention, support and service improvements. The information needed for a task depends on the service you choose and the checks that apply to it.'),
        SettingsArticleSection('Service providers and records',
            'A transaction or verification may involve a payment, banking, identity or technical service provider. Information relevant to that service may need to be shared with the provider. Record handling also depends on the transaction, applicable obligations and unresolved support requests.'),
        SettingsArticleSection('Your privacy requests',
            'Contact Customer Support to ask about your information, request a correction or discuss account closure. Include the email address associated with your account and the nature of your request. Do not include your password, security PIN or verification codes.'),
        SettingsArticleSection('Keeping this policy current',
            'Review this page when your use of Davochain changes or when an updated policy is made available. For questions about a particular record or request, contact Customer Support from Settings.'),
      ]),
  'Terms and Condition': SettingsArticle(
      heading: 'Using Davochain',
      introduction:
          'Read these terms before creating an account or submitting a transaction. They describe the responsibilities that help keep your account and transactions clear.',
      sections: [
        SettingsArticleSection('Your account',
            'Provide accurate account information, complete the verification requested for a service and keep your access credentials private. Use an account you are authorised to operate. Contact Customer Support if you believe someone else has accessed it.'),
        SettingsArticleSection('Review before you confirm',
            'Check the asset, network, destination, amount, exchange rate and any fees shown in the review screen. Confirm only when the details match your intention. A quote or estimate should be checked again before submitting a new transaction.'),
        SettingsArticleSection('Transaction status',
            'Submission, processing and completion are different stages. A pending status means a final outcome has not yet been confirmed. Use transaction details and the reference to follow progress or discuss a transaction with support.'),
        SettingsArticleSection('Crypto deposits and transfers',
            'Use the address and network displayed for the asset you selected. Review the destination carefully before sending. Do not treat an address display, copied address or shared QR code as confirmation that a deposit has arrived.'),
        SettingsArticleSection('Gift-card transactions',
            'Choose the matching brand, country, card type and value. Read the displayed trade terms and provide clear evidence when requested. Keep the original card and relevant purchase information while a trade is being reviewed. Submit only cards you are authorised to trade.'),
        SettingsArticleSection('Responsible use',
            'Do not use Davochain to misrepresent your identity, submit altered evidence, trade unauthorised cards or attempt to bypass account controls. Raise suspected mistakes or unauthorised activity through Customer Support with the relevant transaction reference.'),
        SettingsArticleSection('Questions and disputes',
            'For a transaction question, provide its reference, the date and a concise description of the issue. Keep passwords, security PINs and verification codes private. Review this page and the Privacy Policy when an updated version is made available.'),
      ]),
  'FAQs': SettingsArticle(
      heading: 'Help with your account',
      introduction:
          'Find answers about trading, gift cards, verification and transaction status.',
      questions: true,
      sections: [
        SettingsArticleSection('How do I buy, sell or swap crypto?',
            'Open Trade and choose Buy, Sell or Swap. Use the currency selector to choose an asset, enter an amount and review the details before confirming. Available options are shown in the relevant selector.'),
        SettingsArticleSection('Why is my transaction pending?',
            'Pending means a final outcome has not yet been confirmed. Open the transaction details to check its status and reference. If you need help, share that reference with Customer Support rather than submitting the same request repeatedly.'),
        SettingsArticleSection('How do I choose the right gift card?',
            'Open Gift Cards, choose Buy or Sell, then select the brand and matching subcategory. Check the country, physical or digital type, value and trade terms before continuing.'),
        SettingsArticleSection('Where can I find my deposit address?',
            'Choose Deposit and select the crypto asset. Check the network shown on the deposit screen. Use Show all to read the complete address, or Copy Address to copy it without retyping.'),
        SettingsArticleSection('What should I check before a withdrawal?',
            'Review the selected wallet, available balance, destination account, amount, applicable limit and fee. Check the final review screen before entering your payment PIN.'),
        SettingsArticleSection('Why can I not resend a verification code yet?',
            'The countdown shows when another code can be requested. Wait for it to finish, check the destination shown on the screen and choose Resend Code. Enter the code sent for the current verification request.'),
        SettingsArticleSection('Can I use fingerprint to sign in?',
            'Open the fingerprint settings to review the options available on your device. You can use your password for account access. Payment confirmation has a separate fingerprint setting and still depends on the transaction controls that apply.'),
        SettingsArticleSection('How do I contact support?',
            'Open Customer Support from Settings. Include a clear description and a transaction reference when relevant. Never send your password, payment PIN or verification codes.'),
      ]),
  'About Us': SettingsArticle(
      heading: 'Your assets. One clear view.',
      introduction:
          'Davochain brings crypto trading, gift cards and wallet activity into one straightforward experience.',
      sections: [
        SettingsArticleSection('A place for everyday transactions',
            'Move between buying, selling and swapping crypto, explore gift-card options and review your wallet activity from the same app. Each journey brings the details you need into focus before you confirm.'),
        SettingsArticleSection('Clarity before confirmation',
            'The amount, selected asset, destination, quote and applicable fees belong in the conversation before a transaction is submitted. Review screens, references and receipts help you keep track of the choices you make.'),
        SettingsArticleSection('A view of what you hold',
            'Portfolio brings your holdings and allocation together. Transaction history and individual details help you follow activity without losing sight of your wallet.'),
        SettingsArticleSection('Control over your account',
            'Account settings bring verification, password, fingerprint and notification options together. Review them regularly and choose the options that suit the way you use your device.'),
        SettingsArticleSection('Help when you need it',
            'Customer Support is available from Settings for account and transaction questions. Start with the relevant reference and a description of what happened so your request is clear from the beginning.'),
      ]),
};
