#pragma once
#include <iostream>
#include <iomanip>
#include <exception>
#include <string>
#include <GeographicLib/UTMUPS.hpp>
#include <GeographicLib/Geocentric.hpp>

namespace utm_converter
{

struct UtmCoor
{
    double x;
    double y;
    double z;
    int zone;
    bool northp;
};

struct EcefCoor
{
    double x;
    double y;
    double z;
};

struct Wgs84
{
    double lat;
    double lon;
    double alt;
};

/**
 * @brief convert wgs coordinates to utm coordinates
 * 
 * @param wgs84 structure of Wgs84 as an input
 * @return UtmCoor 
 */
UtmCoor lla2utm(const Wgs84 &wgs84);

/**
 * @brief conver utm coordinates to wgs 84 coordinates
 * 
 * @param utm structure of utm as an input
 * @return Wgs84 
 */
Wgs84 utm2lla(const UtmCoor &utm);

/**
 * @brief convert ecef coordinates to wgs-84 coordinates 
 * 
 * @param ecef 
 * @return Wgs84 
 */
Wgs84 ecef2lla(const EcefCoor &ecef);

/**
 * @brief conver wgs-84 coordinates to ecef coordinates
 * 
 * @param wgs84 
 * @return EcefCoor 
 */
EcefCoor lla2ecef(const Wgs84 &wgs84);

} // namespace utm_converter
