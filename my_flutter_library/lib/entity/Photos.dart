import 'dart:convert' show json;

class Photos {

    int total;
    int total_pages;
    List<Photo> results;

    Photos.fromParams({this.total, this.total_pages, this.results});

    factory Photos(jsonStr) => jsonStr == null ? null : jsonStr is String ? new Photos.fromJson(json.decode(jsonStr)) : new Photos.fromJson(jsonStr);

    Photos.fromJson(jsonRes) {

        total = jsonRes['total'];
        total_pages = jsonRes['total_pages'];
        results = jsonRes['results'] == null ? null : [];

        for (var resultsItem in results == null ? [] : jsonRes['results']){
            results.add(resultsItem == null ? null : new Photo.fromJson(resultsItem));
        }
    }

    @override
    String toString() {
        return '{"total": $total,"total_pages": $total_pages,"results": $results}';
    }
}

class Photo {

    String description;
    String promoted_at;
    int height;
    int likes;
    int width;
    bool liked_by_user;
    String alt_description;
    String color;
    String created_at;
    String id;
    String updated_at;
    List<dynamic> categories;
    List<dynamic> current_user_collections;
    List<Tag> tags;
    Links links;
    Sponsorship sponsorship;
    Urls urls;
    User user;

    Photo.fromParams({this.description, this.promoted_at, this.height, this.likes, this.width, this.liked_by_user, this.alt_description, this.color, this.created_at, this.id, this.updated_at, this.categories, this.current_user_collections, this.tags, this.links, this.sponsorship, this.urls, this.user});

    Photo.fromJson(jsonRes) {
        description = jsonRes['description'];
        promoted_at = jsonRes['promoted_at'];
        height = jsonRes['height'];
        likes = jsonRes['likes'];
        width = jsonRes['width'];
        liked_by_user = jsonRes['liked_by_user'];
        alt_description = jsonRes['alt_description'];
        color = jsonRes['color'];
        created_at = jsonRes['created_at'];
        id = jsonRes['id'];
        updated_at = jsonRes['updated_at'];
        categories = jsonRes['categories'] == null ? null : [];

        for (var categoriesItem in categories == null ? [] : jsonRes['categories']){
            categories.add(categoriesItem);
        }

        current_user_collections = jsonRes['current_user_collections'] == null ? null : [];

        for (var current_user_collectionsItem in current_user_collections == null ? [] : jsonRes['current_user_collections']){
            current_user_collections.add(current_user_collectionsItem);
        }

        tags = jsonRes['tags'] == null ? null : [];

        for (var tagsItem in tags == null ? [] : jsonRes['tags']){
            tags.add(tagsItem == null ? null : new Tag.fromJson(tagsItem));
        }

        links = jsonRes['links'] == null ? null : new Links.fromJson(jsonRes['links']);
        sponsorship = jsonRes['sponsorship'] == null ? null : new Sponsorship.fromJson(jsonRes['sponsorship']);
        urls = jsonRes['urls'] == null ? null : new Urls.fromJson(jsonRes['urls']);
        user = jsonRes['user'] == null ? null : new User.fromJson(jsonRes['user']);
    }

    @override
    String toString() {
        return '{"description": ${description != null?'${json.encode(description)}':'null'},"promoted_at": ${promoted_at != null?'${json.encode(promoted_at)}':'null'},"height": $height,"likes": $likes,"width": $width,"liked_by_user": $liked_by_user,"alt_description": ${alt_description != null?'${json.encode(alt_description)}':'null'},"color": ${color != null?'${json.encode(color)}':'null'},"created_at": ${created_at != null?'${json.encode(created_at)}':'null'},"id": ${id != null?'${json.encode(id)}':'null'},"updated_at": ${updated_at != null?'${json.encode(updated_at)}':'null'},"categories": $categories,"current_user_collections": $current_user_collections,"tags": $tags,"links": $links,"sponsorship": $sponsorship,"urls": $urls,"user": $user}';
    }
}

class User {

    String last_name;
    String location;
    int total_collections;
    int total_likes;
    int total_photos;
    bool accepted_tos;
    String bio;
    String first_name;
    String id;
    String instagram_username;
    String name;
    String portfolio_url;
    String twitter_username;
    String updated_at;
    String username;
    UserLins links;
    UserProfileImg profile_image;

    User.fromParams({this.last_name, this.location, this.total_collections, this.total_likes, this.total_photos, this.accepted_tos, this.bio, this.first_name, this.id, this.instagram_username, this.name, this.portfolio_url, this.twitter_username, this.updated_at, this.username, this.links, this.profile_image});

    User.fromJson(jsonRes) {
        last_name = jsonRes['last_name'];
        location = jsonRes['location'];
        total_collections = jsonRes['total_collections'];
        total_likes = jsonRes['total_likes'];
        total_photos = jsonRes['total_photos'];
        accepted_tos = jsonRes['accepted_tos'];
        bio = jsonRes['bio'];
        first_name = jsonRes['first_name'];
        id = jsonRes['id'];
        instagram_username = jsonRes['instagram_username'];
        name = jsonRes['name'];
        portfolio_url = jsonRes['portfolio_url'];
        twitter_username = jsonRes['twitter_username'];
        updated_at = jsonRes['updated_at'];
        username = jsonRes['username'];
        links = jsonRes['links'] == null ? null : new UserLins.fromJson(jsonRes['links']);
        profile_image = jsonRes['profile_image'] == null ? null : new UserProfileImg.fromJson(jsonRes['profile_image']);
    }

    @override
    String toString() {
        return '{"last_name": ${last_name != null?'${json.encode(last_name)}':'null'},"location": ${location != null?'${json.encode(location)}':'null'},"total_collections": $total_collections,"total_likes": $total_likes,"total_photos": $total_photos,"accepted_tos": $accepted_tos,"bio": ${bio != null?'${json.encode(bio)}':'null'},"first_name": ${first_name != null?'${json.encode(first_name)}':'null'},"id": ${id != null?'${json.encode(id)}':'null'},"instagram_username": ${instagram_username != null?'${json.encode(instagram_username)}':'null'},"name": ${name != null?'${json.encode(name)}':'null'},"portfolio_url": ${portfolio_url != null?'${json.encode(portfolio_url)}':'null'},"twitter_username": ${twitter_username != null?'${json.encode(twitter_username)}':'null'},"updated_at": ${updated_at != null?'${json.encode(updated_at)}':'null'},"username": ${username != null?'${json.encode(username)}':'null'},"links": $links,"profile_image": $profile_image}';
    }
}

class UserProfileImg {

    String large;
    String medium;
    String small;

    UserProfileImg.fromParams({this.large, this.medium, this.small});

    UserProfileImg.fromJson(jsonRes) {
        large = jsonRes['large'];
        medium = jsonRes['medium'];
        small = jsonRes['small'];
    }

    @override
    String toString() {
        return '{"large": ${large != null?'${json.encode(large)}':'null'},"medium": ${medium != null?'${json.encode(medium)}':'null'},"small": ${small != null?'${json.encode(small)}':'null'}}';
    }
}

class UserLins {

    String followers;
    String following;
    String html;
    String likes;
    String photos;
    String portfolio;
    String self;

    UserLins.fromParams({this.followers, this.following, this.html, this.likes, this.photos, this.portfolio, this.self});

    UserLins.fromJson(jsonRes) {
        followers = jsonRes['followers'];
        following = jsonRes['following'];
        html = jsonRes['html'];
        likes = jsonRes['likes'];
        photos = jsonRes['photos'];
        portfolio = jsonRes['portfolio'];
        self = jsonRes['self'];
    }

    @override
    String toString() {
        return '{"followers": ${followers != null?'${json.encode(followers)}':'null'},"following": ${following != null?'${json.encode(following)}':'null'},"html": ${html != null?'${json.encode(html)}':'null'},"likes": ${likes != null?'${json.encode(likes)}':'null'},"photos": ${photos != null?'${json.encode(photos)}':'null'},"portfolio": ${portfolio != null?'${json.encode(portfolio)}':'null'},"self": ${self != null?'${json.encode(self)}':'null'}}';
    }
}

class Urls {

    String full;
    String raw;
    String regular;
    String small;
    String thumb;

    Urls.fromParams({this.full, this.raw, this.regular, this.small, this.thumb});

    Urls.fromJson(jsonRes) {
        full = jsonRes['full'];
        raw = jsonRes['raw'];
        regular = jsonRes['regular'];
        small = jsonRes['small'];
        thumb = jsonRes['thumb'];
    }

    @override
    String toString() {
        return '{"full": ${full != null?'${json.encode(full)}':'null'},"raw": ${raw != null?'${json.encode(raw)}':'null'},"regular": ${regular != null?'${json.encode(regular)}':'null'},"small": ${small != null?'${json.encode(small)}':'null'},"thumb": ${thumb != null?'${json.encode(thumb)}':'null'}}';
    }
}

class Sponsorship {

    String tagline;
    String tagline_url;
    List<String> impression_urls;
    Sponsor sponsor;

    Sponsorship.fromParams({this.tagline, this.tagline_url, this.impression_urls, this.sponsor});

    Sponsorship.fromJson(jsonRes) {
        tagline = jsonRes['tagline'];
        tagline_url = jsonRes['tagline_url'];
        impression_urls = jsonRes['impression_urls'] == null ? null : [];

        for (var impression_urlsItem in impression_urls == null ? [] : jsonRes['impression_urls']){
            impression_urls.add(impression_urlsItem);
        }

        sponsor = jsonRes['sponsor'] == null ? null : new Sponsor.fromJson(jsonRes['sponsor']);
    }

    @override
    String toString() {
        return '{"tagline": ${tagline != null?'${json.encode(tagline)}':'null'},"tagline_url": ${tagline_url != null?'${json.encode(tagline_url)}':'null'},"impression_urls": $impression_urls,"sponsor": $sponsor}';
    }
}

class Sponsor {

    String last_name;
    String location;
    int total_collections;
    int total_likes;
    int total_photos;
    bool accepted_tos;
    String bio;
    String first_name;
    String id;
    String instagram_username;
    String name;
    String portfolio_url;
    String twitter_username;
    String updated_at;
    String username;
    SponsorLinks links;
    SponsorProfileImg profile_image;

    Sponsor.fromParams({this.last_name, this.location, this.total_collections, this.total_likes, this.total_photos, this.accepted_tos, this.bio, this.first_name, this.id, this.instagram_username, this.name, this.portfolio_url, this.twitter_username, this.updated_at, this.username, this.links, this.profile_image});

    Sponsor.fromJson(jsonRes) {
        last_name = jsonRes['last_name'];
        location = jsonRes['location'];
        total_collections = jsonRes['total_collections'];
        total_likes = jsonRes['total_likes'];
        total_photos = jsonRes['total_photos'];
        accepted_tos = jsonRes['accepted_tos'];
        bio = jsonRes['bio'];
        first_name = jsonRes['first_name'];
        id = jsonRes['id'];
        instagram_username = jsonRes['instagram_username'];
        name = jsonRes['name'];
        portfolio_url = jsonRes['portfolio_url'];
        twitter_username = jsonRes['twitter_username'];
        updated_at = jsonRes['updated_at'];
        username = jsonRes['username'];
        links = jsonRes['links'] == null ? null : new SponsorLinks.fromJson(jsonRes['links']);
        profile_image = jsonRes['profile_image'] == null ? null : new SponsorProfileImg.fromJson(jsonRes['profile_image']);
    }

    @override
    String toString() {
        return '{"last_name": ${last_name != null?'${json.encode(last_name)}':'null'},"location": ${location != null?'${json.encode(location)}':'null'},"total_collections": $total_collections,"total_likes": $total_likes,"total_photos": $total_photos,"accepted_tos": $accepted_tos,"bio": ${bio != null?'${json.encode(bio)}':'null'},"first_name": ${first_name != null?'${json.encode(first_name)}':'null'},"id": ${id != null?'${json.encode(id)}':'null'},"instagram_username": ${instagram_username != null?'${json.encode(instagram_username)}':'null'},"name": ${name != null?'${json.encode(name)}':'null'},"portfolio_url": ${portfolio_url != null?'${json.encode(portfolio_url)}':'null'},"twitter_username": ${twitter_username != null?'${json.encode(twitter_username)}':'null'},"updated_at": ${updated_at != null?'${json.encode(updated_at)}':'null'},"username": ${username != null?'${json.encode(username)}':'null'},"links": $links,"profile_image": $profile_image}';
    }
}

class SponsorProfileImg {

    String large;
    String medium;
    String small;

    SponsorProfileImg.fromParams({this.large, this.medium, this.small});

    SponsorProfileImg.fromJson(jsonRes) {
        large = jsonRes['large'];
        medium = jsonRes['medium'];
        small = jsonRes['small'];
    }

    @override
    String toString() {
        return '{"large": ${large != null?'${json.encode(large)}':'null'},"medium": ${medium != null?'${json.encode(medium)}':'null'},"small": ${small != null?'${json.encode(small)}':'null'}}';
    }
}

class SponsorLinks {

    String followers;
    String following;
    String html;
    String likes;
    String photos;
    String portfolio;
    String self;

    SponsorLinks.fromParams({this.followers, this.following, this.html, this.likes, this.photos, this.portfolio, this.self});

    SponsorLinks.fromJson(jsonRes) {
        followers = jsonRes['followers'];
        following = jsonRes['following'];
        html = jsonRes['html'];
        likes = jsonRes['likes'];
        photos = jsonRes['photos'];
        portfolio = jsonRes['portfolio'];
        self = jsonRes['self'];
    }

    @override
    String toString() {
        return '{"followers": ${followers != null?'${json.encode(followers)}':'null'},"following": ${following != null?'${json.encode(following)}':'null'},"html": ${html != null?'${json.encode(html)}':'null'},"likes": ${likes != null?'${json.encode(likes)}':'null'},"photos": ${photos != null?'${json.encode(photos)}':'null'},"portfolio": ${portfolio != null?'${json.encode(portfolio)}':'null'},"self": ${self != null?'${json.encode(self)}':'null'}}';
    }
}

class Links {

    String download;
    String download_location;
    String html;
    String self;

    Links.fromParams({this.download, this.download_location, this.html, this.self});

    Links.fromJson(jsonRes) {
        download = jsonRes['download'];
        download_location = jsonRes['download_location'];
        html = jsonRes['html'];
        self = jsonRes['self'];
    }

    @override
    String toString() {
        return '{"download": ${download != null?'${json.encode(download)}':'null'},"download_location": ${download_location != null?'${json.encode(download_location)}':'null'},"html": ${html != null?'${json.encode(html)}':'null'},"self": ${self != null?'${json.encode(self)}':'null'}}';
    }
}

class Tag {

    String title;
    String type;

    Tag.fromParams({this.title, this.type});

    Tag.fromJson(jsonRes) {
        title = jsonRes['title'];
        type = jsonRes['type'];
    }

    @override
    String toString() {
        return '{"title": ${title != null?'${json.encode(title)}':'null'},"type": ${type != null?'${json.encode(type)}':'null'}}';
    }
}

