#include "utm_converter.hpp"

namespace utm_converter
{
UtmCoor lla2utm(const Wgs84 &wgs84)
{
    UtmCoor utm;
    GeographicLib::UTMUPS::Forward(wgs84.lat, wgs84.lon, utm.zone, utm.northp, utm.x, utm.y);
    utm.z = wgs84.alt;
    std::string zonestr = GeographicLib::UTMUPS::EncodeZone(utm.zone, utm.northp);
    std::cout << std::fixed << std::setprecision(10)
        << zonestr << " " << utm.x << " " << utm.y << " " << utm.z << "\n";
    return utm;
}

Wgs84 utm2lla(const UtmCoor &utm)
{
    Wgs84 wgs84;
    GeographicLib::UTMUPS::Reverse(utm.zone, utm.northp, utm.x, utm.y, wgs84.lat, wgs84.lon);
    wgs84.alt = utm.z;
    std::cout << wgs84.lat << " " << wgs84.lon << " " << wgs84.alt << "\n"; 
    return wgs84;
}
    
Wgs84 ecef2lla(const EcefCoor &ecef)
{
    Wgs84 wgs84;
    GeographicLib::Geocentric geocent(GeographicLib::Constants::WGS84_a(), GeographicLib::Constants::WGS84_f());
    geocent.Reverse(ecef.x, ecef.y, ecef.z, wgs84.lat, wgs84.lon, wgs84.alt);
    std::cout << wgs84.lat << " " << wgs84.lon << " " << wgs84.alt << "\n"; 
    return wgs84; 
}
} // namespace utmconverter
