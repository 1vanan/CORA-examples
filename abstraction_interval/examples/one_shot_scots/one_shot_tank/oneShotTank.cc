//
// Created by Иван Федотов on 29.12.20.
//

#include <iostream>
#include <array>

/* SCOTS header */
#include "scots.hh"
/* ode solver */
#include "RungeKutta4.hh"

/* time profiling */
#include "TicToc.hh"
/* memory profiling */
#include <sys/time.h>
#include <sys/resource.h>
#include <math.h>

struct rusage usage;

/* state space dim */
const int state_dim = 6;
/* input space dim */
const int input_dim = 6;

/* sampling time */
const double tau = 3;


const double k = 0.015;
const double k2 = 0.01;
const double g = 9.81;

double left_bound[state_dim] = {1.85, 2.3, 3.14, 2, 8, 4};
double right_bound[state_dim] = {10, 10, 5, 3, 10, 5.4};

/*
 * data types for the state space elements and input space
 * elements used in uniform grid and ode solvers
 */
using state_type = std::array<double, state_dim>;
using input_type = std::array<double, input_dim>;
using namespace std;

/* abbrev of the type for abstract states and inputs */
using abs_type = scots::abs_type;

/* we integrate the vehicle ode by tau sec (the result is stored in x)  */
auto tank_post = [](state_type &x, const input_type &u) {
    /* the ode describing the vehicle */
    auto rhs = [](state_type &xx, const state_type &x, const input_type &u) {

        // differential equations
        xx[0] = 0.1 + k2 * (4 - x[5]) - k * sqrt(2 * g) * sqrt(x[0]); // tank 1
        xx[1] = k * sqrt(2 * g) * (sqrt(x[0]) - sqrt(x[1])); // tank 2
        xx[2] = k * sqrt(2 * g) * (sqrt(x[1]) - sqrt(x[2])); // tank 3
        xx[3] = k * sqrt(2 * g) * (sqrt(x[2]) - sqrt(x[3])); // tank 4
        xx[4] = k * sqrt(2 * g) * (sqrt(x[3]) - sqrt(x[4])); // tank 5
        xx[5] = k * sqrt(2 * g) * (sqrt(x[4]) - sqrt(x[5])); // tank 6
    };
    /* simulate (use 10 intermediate steps in the ode solver) */
    scots::runge_kutta_fixed4(rhs, x, u, state_dim, tau, 5);
};

/* we integrate the growth bound by 0.3 sec (the result is stored in r)  */
auto radius_post = [](state_type &r, const state_type &, const input_type &u) {

    auto rhs1 = [](state_type &rr, const state_type &r, const input_type &u) {
        const state_type w = {{0.005}};
        double L[state_dim][state_dim];
        L[0][0] = -k * sqrt(2 * g) / (2 * sqrt(right_bound[0]));
        L[0][5] = -k2;

        L[1][0] = k * sqrt(2 * g) / (2 * sqrt(left_bound[0]));
        L[1][1] = -k * sqrt(2 * g) / (2 * sqrt(right_bound[1]));

        L[2][1] = k * sqrt(2 * g) / (2 * sqrt(left_bound[1]));
        L[2][2] = -k * sqrt(2 * g) / (2 * sqrt(right_bound[2]));

        L[3][2] = k * sqrt(2 * g) / (2 * sqrt(left_bound[2]));
        L[3][3] = -k * sqrt(2 * g) / (2 * sqrt(right_bound[3]));

        L[4][3] = k * sqrt(2 * g) / (2 * sqrt(left_bound[3]));
        L[4][4] = -k * sqrt(2 * g) / (2 * sqrt(right_bound[4]));

        L[5][4] = k * sqrt(2 * g) / (2 * sqrt(left_bound[4]));
        L[5][5] = -k * sqrt(2 * g) / (2 * sqrt(right_bound[5]));

        rr[0] = L[0][0] * r[0] + L[0][5] * r[5] + w[0];
        rr[1] = L[1][0] * r[0] + L[1][1] * r[1];
        rr[2] = L[2][1] * r[1] + L[2][2] * r[2];
        rr[3] = L[3][2] * r[2] + L[3][3] * r[3];
        rr[4] = L[4][3] * r[3] + L[4][4] * r[4];
        rr[5] = L[5][4] * r[4] + L[5][5] * r[5];
    };

    /* use 10 intermediate steps */
    scots::runge_kutta_fixed4(rhs1, r, u, state_dim, tau, 5);
};

int main() {
    double rad = 0.005;
    /* to measure time */
    TicToc tt;
    state_type x = {2, 4, 4, 2, 10, 4};
    state_type r;
    input_type u;

    for (int i = 0; i < state_dim; i++) {
        r[i] = rad;
    }

    int total = 0;
    bool inside = true;

    for (int j = 0; j < 10; j++) {
        // solution without disturbance
        tank_post(x, u);
        // solution with disturbance
        radius_post(r, x, u);
        int totalLocal = 1;
        for (int i = 0; i < state_dim; i++) {
            double left = x[i] - r[i];
            double right = x[i] + r[i];
            if (right < left_bound[i] || left > right_bound[i]) {
                inside = false;
                break;
            }
            std::cout << "iteration: " << j << "  dimension: " << i << "  left: " << left << "  right: " << right
                      << "\n";

            totalLocal *= ceil(right/(rad * 2)) - floor(left/(rad * 2));

            cout << "num: " << totalLocal << "\n";
        }
        if (!inside) {
            break;
        }
        total += totalLocal;
    }
    std::cout << "total: " << total << "\n";

    return 0;
}
