import 'package:flutter/material.dart';

/// Centralized design constants replicated from the DataNaija prototype.
/// All colors, spacing, typography weights, and dimensions mirror the
/// inline styles and CSS variables in Main.dc.html.

// ── Colors ─────────────────────────────────────────────────────────────

const Color kAccent = Color(0xFF0A7A4C); // primary green (--g)
const Color kAccentAlt1 = Color(0xFF0F766E); // theme option
const Color kAccentAlt2 = Color(0xFF1D4ED8); // theme option
const Color kAccentAlt3 = Color(0xFFB45309); // theme option

/// The accent colors the customer can pick from.
const List<Color> kThemeAccentOptions = [
  kAccent,
  kAccentAlt1,
  kAccentAlt2,
  kAccentAlt3,
];

const Color kBackground = Color(0xFFFFFFFF);
const Color kHomeBackground = Color(0xFFF6F9F7);
const Color kSurface = Color(0xFFFFFFFF);

const Color kTextPrimary = Color(0xFF10231A);
const Color kTextMuted = Color(0xFF5F6F66);
const Color kTextOnAccent = Color(0xFFFFFFFF);
const Color kMutedOnWallet = Color(0xFFCFEBDD);

const Color kBorderLight = Color(0xFFE3EAE6);
const Color kBorderMedium = Color(0xFFD5DED9);
const Color kCardBorder = Color(0xFFE3EAE6);

const Color kWalletGradientStart = Color(0xFF0A7A4C);
const Color kWalletGradientEnd = Color(0xFF09663F);

const Color kPillSuccessBg = Color(0xFFDDF3E9);
const Color kPillSuccessFg = Color(0xFF0A5C3E);
const Color kPillPendingBg = Color(0xFFFFF1D6);
const Color kPillPendingFg = Color(0xFF8A5A00);
const Color kPillFailedBg = Color(0xFFFDE4E1);
const Color kPillFailedFg = Color(0xFF9B1C12);

const Color kAmountPositive = Color(0xFF0B7A4B);
const Color kAmountNegative = Color(0xFF10231A);

const Color kScrimBg = Color(0x8C10231A); // rgba(16,35,26,0.55)
const Color kSheetBg = Color(0xFFFFFFFF);

// ── Dimensions ─────────────────────────────────────────────────────────

const double kPagePadding = 20.0;

const double kBorderRadiusCard = 18.0;
const double kBorderRadiusButton = 14.0;
const double kBorderRadiusInput = 12.0;
const double kBorderRadiusPill = 999.0;
const double kBorderRadiusWallet = 20.0;
const double kBorderRadiusSheet = 26.0;

const double kButtonMinHeight = 50.0;
const double kInputMinHeight = 50.0;

const double kNavBarHeight = 72.0;

const double kBigIconSize = 44.0;

// ── Typography (Plus Jakarta Sans) ────────────────────────────────────

const String kFontFamily = 'Plus Jakarta Sans';

const double kFontSizeLabel = 13.0;
const double kFontSizeBody = 14.0;
const double kFontSizeButton = 15.0;
const double kFontSizeHeading = 19.0;
const double kFontSizeH1 = 25.0;

const FontWeight kWeightMedium = FontWeight.w500;
const FontWeight kWeightBold = FontWeight.w700;
const FontWeight kWeightExtraBold = FontWeight.w800;

// ── Strings ────────────────────────────────────────────────────────────

const String kMockBankName = '[BANK NAME]';
const String kReferralCode = 'CHINEDU12';
const String kSupportContact = '[SUPPORT CONTACT]';

// ── WhatsApp support ────────────────────────────────────────────────────

/// Official WhatsApp Channel URL.
const String kWhatsAppChannelUrl =
    'https://whatsapp.com/channel/0029Vb9lWtd2Jl8GYqy2YP0r';

/// WhatsApp contact number in international format (no +, spaces, or punctuation).
const String kWhatsAppPhoneNumber = '2348126573474';

/// Formatted display version of the contact number.
const String kWhatsAppPhoneDisplay = '+234 812 657 3474';

/// Prefilled message for the WhatsApp support conversation.
const String kWhatsAppSupportMessage =
    'Hello, I need assistance with your application.';

/// Direct WhatsApp deep link (wa.me) for starting a conversation.
const String kWhatsAppDirectLink = 'https://wa.me/$kWhatsAppPhoneNumber';
