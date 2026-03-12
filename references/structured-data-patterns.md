# Structured Data Patterns for AI SEO

JSON-LD templates by page type. Copy, customize, and add to `<head>`.

## Homepage — WebSite + Organization

```json
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "name": "[Site Name]",
      "url": "https://example.com",
      "description": "[Specific description with numbers]",
      "inLanguage": ["en", "ko", "zh"],
      "potentialAction": {
        "@type": "SearchAction",
        "target": "https://example.com/search?q={search_term_string}",
        "query-input": "required name=search_term_string"
      }
    },
    {
      "@type": "Organization",
      "name": "[Company Name]",
      "url": "https://example.com",
      "logo": "https://example.com/logo.png",
      "sameAs": [
        "https://twitter.com/example",
        "https://github.com/example"
      ]
    }
  ]
}
```

## Product Page

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "[Product Name]",
  "description": "[Product description]",
  "image": "https://example.com/product.jpg",
  "brand": { "@type": "Brand", "name": "[Brand]" },
  "offers": {
    "@type": "Offer",
    "price": "29.99",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock",
    "url": "https://example.com/product"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "reviewCount": "127"
  }
}
```

## Article / Blog Post

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "[Article Title]",
  "description": "[Summary]",
  "author": {
    "@type": "Person",
    "name": "[Author Name]",
    "url": "https://example.com/author"
  },
  "publisher": {
    "@type": "Organization",
    "name": "[Site Name]",
    "logo": { "@type": "ImageObject", "url": "https://example.com/logo.png" }
  },
  "datePublished": "2026-01-15",
  "dateModified": "2026-03-01",
  "image": "https://example.com/article-image.jpg"
}
```

## FAQ Page

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "[Question 1]",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[Answer 1 — be specific, include numbers]"
      }
    },
    {
      "@type": "Question",
      "name": "[Question 2]",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "[Answer 2]"
      }
    }
  ]
}
```

## Local Business

```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "[Business Name]",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "[Street]",
    "addressLocality": "[City]",
    "addressRegion": "[State/Province]",
    "postalCode": "[ZIP]",
    "addressCountry": "[Country Code]"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": 33.462,
    "longitude": 126.331
  },
  "telephone": "+82-64-xxx-xxxx",
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
      "opens": "09:00",
      "closes": "18:00"
    }
  ]
}
```

## Tourist Attraction / Point of Interest

```json
{
  "@context": "https://schema.org",
  "@type": "TouristAttraction",
  "name": "[Spot Name]",
  "description": "[Description with historical/cultural context]",
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": 33.462,
    "longitude": 126.331
  },
  "image": "https://example.com/spot.jpg",
  "touristType": ["Nature tourism", "Cultural tourism"],
  "containedInPlace": {
    "@type": "TouristDestination",
    "name": "[Region Name]"
  }
}
```

## HowTo / Guide

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "[Guide Title]",
  "description": "[What this guide helps you do]",
  "totalTime": "PT30M",
  "step": [
    {
      "@type": "HowToStep",
      "position": 1,
      "name": "[Step 1 Title]",
      "text": "[Step 1 description]"
    },
    {
      "@type": "HowToStep",
      "position": 2,
      "name": "[Step 2 Title]",
      "text": "[Step 2 description]"
    }
  ]
}
```

## Validation

Always test structured data with:
- [Google Rich Results Test](https://search.google.com/test/rich-results)
- [Schema.org Validator](https://validator.schema.org/)
